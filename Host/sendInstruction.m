function [response, overlapResponses] = sendInstruction(config, ...
    instruction, tag, data)
%% sendInstruction
% Sends an instruction. config.beacons(1) should be an open serial port.
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   instruction
%     String instruction. Must match one of the instructions in insStruct
%   tag (optional)
%     If the instruction is specific to a bot, tag should be the single
%     character tag of that bot. 
%   data (optional)
%     If the instruction transmits data (i.e. any SET instruction), the
%     value should be in data. 
%
% Returns:
%   response (optional)
%     If the instruction obtains a response from any bots, this value will
%     be non-empty
%   overlapResponses
%     Array of XBeeResponse objects that were received during this
%     instruction, but should be handled as independent requests by the
%     calling function

%% Generate request payload
% Global commands only vary in the destination address. The bots will
% interpret the commands the same way
if contains(instruction,'G_')
    address = XBeeConst.BROADCAST_ADDRESS;
    isGlobal = true;
else
    address = config.tagAddressStruct.(tag);
    isGlobal = false;
end

% Generate instruction hex for message
msg = uint8(config.insStruct.(instruction));
% Generate instruction-specific fields
switch instruction
    % Sending float32 data
    case {'SET_X','SET_Y','SET_A'}
        msg(2:5) = typecast(single(data),'uint8');
    % Sending int16 data
    case {'SET_M_L','SET_M_R'}
        if data > 255
            data = 255;
        elseif data < -255
            data = -255;
        end
        msg(2:3) = typecast(int16(data),'uint8');
    % Sending unsigned long (uint32) data
    case {'GO_F','G_GO_F'}
        msg(2:5) = typecast(uint32(data),'uint8');
    % Sending 3 float32 data
    case 'SET_POS'
        msg(2:13) = typecast(single(data),'uint8');
    case {'GET_NEXT','START_LOCAL'}
        msg(2:9) = typecast(single(data),'uint8');
end

%% Send and validate response

% Generate the XBeeRequest
request = Tx16Request(address,msg,1);
valid = false;

while ~valid
    xbeeResponses = sendAndParse(config.beacons(1), request, true, false);
    valid = true;
    txResponses = TxStatusResponse.empty;
    actualResponses = RobotResponse.empty;
    overlapResponses = XBeeResponse.empty;
    % Need to parse through responses, and ensure all TxStatusResponses are
    % successful. Otherwise, resend the request
    for i = 1:length(xbeeResponses)
        switch xbeeResponses(i).apiId
            case XBeeConst.TX_STATUS_RESPONSE
                txResponses(end+1) = xbeeResponses(i).TxStatusResponse();
                % If any TxStatusResponses are invalid or unsuccessful,
                % break and resend the request
                if ~txResponses(end).isValid || ~txResponses(end).isSuccess
                    valid = false;
                    break
                end
            % Although we're casting to RobotResponse, the API id is still
            % RX16Response
            case XBeeConst.RX_16_RESPONSE
                rResponse = xbeeResponses(i).RobotResponse();
                % If this response is a response to the instruction
                if rResponse.instruction == config.insStruct.(instruction)
                    actualResponses(end+1) = rResponse;
                else
                    % This is the case where a request from another bot was
                    % sent simultaneously. Needs to be returned to caller
                    % and handled seperately
                    overlapResponses(end+1) = xbeeResponses(i);
                end
                % If any RobotResponses are invalid, break and resend the
                % request
                if ~rResponse.isValid
                    valid = false;
                    break
                end
            otherwise
                warning("Weird response received, ignoring");
        end
    end
end

%% Parse response data
response = [];
% If we received response(s)
if ~isempty(actualResponses)
    % For all global responses, need to establish the sort order based on
    % the order of the tag argument. Then, decode responses and sort them
    if isGlobal
        % This constructs the order in which we want the response
        idOrder = arrayfun(@(t) config.tagAddressStruct.(tag(t)), 1:length(tag));
        % Get the actual address order
        receivedOrder = arrayfun(@(x) x.id, actualResponses)';
        switch instruction
            case {'G_GET_X','G_GET_Y','G_GET_A'}
                unsorted = arrayfun(@(x) typecast(x.responseData,'single'),actualResponses)';
            case {'G_GET_T_L','G_GET_T_R'}
                unsorted = arrayfun(@(x) typecast(x.responseData,'int16'),actualResponses)';
            case {'G_GET_POS'}
                % Do all the casts at once cuz why not
                unsorted = arrayfun(@(x) [typecast(x.responseData(1:12),'single')...
                    single(typecast(x.responseData(13:16),'uint32'))],...
                    actualResponses,'UniformOutput',false);
                % Output of the above line is cell array, so convert to
                % matrix
                unsorted = cell2mat(unsorted');
            otherwise
                warning(['Instruction not yet implemented: ' instruction]);
        end
        % Merge the address order with data
        unsorted = [single(receivedOrder) unsorted];
        % Reorder the responses
        [~, Ai] = sort(idOrder);
        [~, Bi] = sort(unsorted(:, 1));
        ABi(Ai) = Bi;
        % Get the final response using the sorted index
        response = unsorted(ABi,:);
        % Remove the ID column
        response = response(:,2:end);
    else
        switch instruction
            % For non-global instructions, rResponses should only have one
            % element. Should check to ensure there is only one...
            case {'GET_X','GET_Y','GET_A'}
                response = typecast(actualResponses.responseData,'single');
            case {'GET_T_L','GET_T_R'}
                response = typecast(actualResponses.responseData,'int16');
            case 'GET_POS'
                response(1) = typecast(actualResponses.responseData(1:4),'single');
                response(2) = typecast(actualResponses.responseData(5:8),'single');
                response(3) = typecast(actualResponses.responseData(9:12),'single');
                response(4) = typecast(actualResponses.responseData(13:16),'uint32');
            % This is in case we don't know how to interpret the data for
            % some reason
            % TODO: START_LOCAL seems to be getting through here.
            % Localization commands like START_LOCAL should not show up
            % here, rather should be contained within getRssi()
            otherwise
                warning(['Instruction not yet implemented: ' instruction]);
        end
    end
end
