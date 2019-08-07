function [nextPosTags, overlapResponses] = handleRequest(config, request)
%% handleRequest
% Asynchrously handles any requests sent to the host by the bots. This
% only really includes requests for localization and for the next
% navigation point
%
% Parameters:
%   config
%     The config struct (See parseConfig.m)
%   request
%     Non-empty array of XBeeResponse objects
%
% Returns:
%   nextPosTags
%     Character vector of bots who have requested their next target point
%   overlapResponses
%     Array of XBeeResponse objects that were received during this
%     instruction, but should be handled as independent requests by the
%     calling function

% TODO: Some requests seem to slip through during the RSSI procedure. Find
% out why this happens

nextPosTags = '';

txResponses = TxStatusResponse.empty;
rResponses = RobotResponse.empty;
overlapResponses = XBeeResponse.empty;

for i = 1:length(request)
    switch request(i).apiId
        case XBeeConst.TX_STATUS_RESPONSE
            txResponses(end+1) = request(i).TxStatusResponse();
            % If any TxStatusResponses are invalid or unsuccessful,
            % break and resend the request
            if ~txResponses(end).isValid || ~txResponses(end).isSuccess
                warning("Invalid TX_STATUS_RESPONSE");
            end
        % Although we're casting to RobotResponse, the API id is still
        % RX16Response
        case XBeeConst.RX_16_RESPONSE
            rResponses(end+1) = request(i).RobotResponse();
            % If any RobotResponses are invalid, break and resend the
            % request
            if ~rResponses(end).isValid
                warning("Invalid ROBOT_RESPONSE");
            end
        otherwise
            warning("Weird response received, ignoring");
    end
end

for i = 1:length(rResponses)
    % Get the char tag
    tag = config.validTags(rResponses(i).id + 1);
    switch rResponses(i).instruction
        % 11 = GET_NEXT
        case 11
            nextPosTags(end+1) = tag;
        % 15 = START_LOCAL
        case 12
            % Get RSSI values from multiple beacon pings
            [rssi, overlap] = getRssi(config, tag);
            overlapResponses = [overlapResponses overlap];
            % Calculate new position from RSSI values
            newPos = localization(config, rssi);
            % Send the new position back to bots to complete localization
            [~, overlap] = sendInstruction(config, 'START_LOCAL', tag, newPos);
            overlapResponses = [overlapResponses overlap];
    end
end
