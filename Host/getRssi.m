function rssi = getRssi(config, tag)
%% getRssi
% Gets the RSSI values from robots
%
% Sequence of beacons is in the order of the config.xml file. See
% parseConfig() for more info on how serial ports should be formatted.
% tags is supplied to ensure the correct ordering of responses.
% Primary beacon (config.xbee) sends G_GET_RSSI to bots. Bots should halt
% and wait for n - 1 beacons to send requests, from which the bots record
% the RSSI values. After the final beacon ping, the bots each send a 
% response to the primary beacon with RSSI values.
%
% Parameters:
%   config
%     Config struct; see parseConfig for details
%   tag
%     Charactor vector of m bot tags
%
% Returns
%   m-by-n int8 array of RSSI values, where each row is the RSSI for a
%   given bot, and each column corresponds to one becon

% TODO: Test this function to ensure it works


% Construct the initialization request
msg = uint8([config.insStruct.G_GET_RSSI length(config.beacons)]);
address = XBeeConst.BROADCAST_ADDRESS;
request = Tx16Request(address, msg, 1);

% Send initialization request
initialResponse = sendAndParse(config.xbee, request);

% Construct generic packet to be sent by each beacon, with dummy ID 0
pingRequest = Tx16Request(XBeeConst.BROADCAST_ADDRESS, ...
    [config.insStruct.PING 0], 1);
% Empty response array
response = XBeeResponse.empty;
for i = 1:length(config.beacons)
    % Replace beacon ID in the ping request
    pingRequest.payload(2) = i;
    % Send the request using the specified beacon
    response(end+1) = sendAndParse(config.beacons(i), pingRequest);
end

% We now expect a response from each robot, sent to the original XBee
% (config.xbee). However, this should be automatic, so we only call parse()
rssiResponse = parse(config.xbee);
% Empty arrays
txResponses = TxStatusResponse.empty;
rResponses = RobotResponse.empty;
% Assume valid unless shown otherwise
valid = true;

for i = 1:length(rssiResponse)
    switch rssiResponse(i).apiId
        case XBeeConst.TX_STATUS_RESPONSE
            txResponses(end+1) = rssiResponse(i).TxStatusResponse();
            % If any TxStatusResponses are invalid or unsuccessful,
            % break and resend the request
            if ~txResponses(end).isValid || ~txResponses(end).isSuccess
                valid = false;
                break
            end
        % Although we're casting to RobotResponse, the API id is still
        % RX16Response
        case XBeeConst.RX_16_RESPONSE
            rResponses(end+1) = rssiResponse(i).RobotResponse();
            % If any RobotResponses are invalid, break and resend the
            % request
            if ~rResponses(end).isValid
                valid = false;
                break
            end
        otherwise
            warning("Weird response received, ignoring");
    end
end

if ~isEmpty(rResponses)
    % This constructs the order in which we want the response
    idOrder = arrayfun(@(t) config.tagAddressStruct.(tag(t)), 1:length(tag));
    % Get the actual address order
    receivedOrder = arrayfun(@(x) x.id, rResponses)';
    % Typecast responseData to int8
    unsorted = arrayfun(@(x) typecast(x.responseData,'int8'),rResponses)';
    % Merge the address order with data
    unsorted = [int8(receivedOrder) unsorted];
    % Reorder the responses
    [~, Ai] = sort(idOrder);
    [~, Bi] = sort(unsorted(:, 1));
    ABi(Ai) = Bi;
    % Get the final response using the sorted index
    rssi = unsorted(ABi,:);
    % Remove the ID column
    rssi = rssi(:,2:end);
end

