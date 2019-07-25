function response = sendInstruction(config, instruction, tag, data)
%% sendInstruction
% Sends an instruction
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   instruction
%     String instruction. Must match one of the instructions in insStruct
%   tag (optional)
%     If the instruction is specific to a bot, botTag should be the single
%     character tag of that bot. 
%     NOTE: If the instruction is 'G_CONF', this should be the number of
%     bots that need to be confirmed
%   data (optional)
%     If the instruction transmits data (i.e. any SET instruction), the
%     value should be in data. All data should be passed in as regular
%     values (e.g. an x position as 1.23, not 123) EXCEPT for the heading,
%     which should be specified in degrees, not radians
%
% Returns:
%   response (optional)
%     If the instruction obtains a response from any bots, this value will
%     be non-empty

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
end

%% Send and validate response

% Generate the XBeeRequest
request = Tx16Request(address,msg,1);
valid = false;

while ~valid
    xbeeResponses = sendAndParse(config.beacons(1), request);
    valid = true;
    txResponses = TxStatusResponse.empty;
    rResponses = RobotResponse.empty;
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
                rResponses(end+1) = xbeeResponses(i).RobotResponse();
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
end

%% Parse response data
% If we received response(s)
if ~isempty(rResponses)
    % For all global responses, need to establish the sort order based on
    % the order of the tag argument. Then, decode responses and sort them
    if isGlobal
        % This constructs the order in which we want the response
        idOrder = arrayfun(@(t) config.tagAddressStruct.(tag(t)), 1:length(tag));
        % Get the actual address order
        receivedOrder = arrayfun(@(x) x.id, rResponses)';
        switch instruction
            case {'G_GET_X','G_GET_Y','G_GET_A'}
                unsorted = arrayfun(@(x) typecast(x.responseData,'single'),rResponses)';
            case {'G_GET_T_L','G_GET_T_R'}
                unsorted = arrayfun(@(x) typecast(x.responseData,'int16'),rResponses)';
            case {'G_GET_POS'}
                % Do all the casts at once cuz why not
                unsorted = arrayfun(@(x) [typecast(x.responseData(1:12),'single')...
                    single(typecast(x.responseData(13:16),'uint32'))],...
                    rResponses,'UniformOutput',false);
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
                response = typecast(rResponses.responseData,'single');
            case {'GET_T_L','GET_T_R'}
                response = typecast(rResponses.responseData,'int16');
            case 'GET_POS'
                response(1) = typecast(rResponses.responseData(1:4),'single');
                response(2) = typecast(rResponses.responseData(5:8),'single');
                response(3) = typecast(rResponses.responseData(9:12),'single');
                response(4) = typecast(rResponses.responseData(13:16),'uint32');
            % This is in case we don't know how to interpret the data for
            % some reason
            otherwise
                warning(['Instruction not yet implemented: ' instruction]);
        end
    end
end

%% Old code
% switch instruction
%     case {'GO','STOP'}
%         while true
%             fwrite(config.xbee,B0);
%             [~, count] = fread(config.xbee,1,'uint8');
%             if count, break; end
%         end
%     case {'G_CONF','G_GO','G_RESET','G_STOP'}
%         while true
%             fwrite(config.xbee,B0);
%             [~, count] = fread(config.xbee,tag,'uint8');
%             if count==tag, break; end
%         end
%     % GET instructions
%     case {'G_GET_X', 'G_GET_Y'}
%         % Need to receive n 2-byte responses, decode the id, translate ids
%         % to tags, lookup tags to indices in 'tag' vector, and return
%         % values
%         while true
%             fwrite(config.xbee, B0);
%             [rslt, count] = fread(config.xbee,[2 length(tag)],'uint8');
%             if count==2*length(tag), break; end
%         end
%         response = zeros(length(tag),1);
%         % transpose so each row of rslt is the 2 byte response of each bot
%         rslt = uint16(rslt)';
%         % Isolate leading 3 bits to get IDs
%         allIds = bitshift(bitand(rslt(:,1),224),-5);
%         for i = 1:length(tag)
%             % Find the index in rslt corresponding to tag(i)
%             index = find(config.tagIdStruct.(tag(i))==allIds);
%             % Piece the two bytes together
%             response(i) = bitor(bitshift(rslt(index,1),8),rslt(index,2));
%             % If number is negative (i.e. 13th bit = 1)
%             if bitand(response(i),4096)
%                 % Reverse 2's complement, mask the leading 3 ID bits
%                 % Then divide by 100, and negate result
%                 response(i) = -double(bitand(bitcmp(int16(response(i)-1)),8191))/100;
%             else
%                 % If positive, just mask the leading 3 ID bits and divide
%                 response(i) = bitand(response(i),8191)/100;
%             end
%         end
%     case 'G_GET_A'
%         while true
%             fwrite(config.xbee, B0);
%             [rslt, count] = fread(config.xbee,[2 length(tag)],'uint8');
%             if count==2*length(tag), break; end
%         end
%         response = zeros(length(tag),1);
%         % transpose so each row of rslt is the 2 byte response of each bot
%         rslt = rslt';
%         % Isolate leading 3 bits to get IDs
%         allIds = bitshift(bitand(rslt(:,1),224),-5);
%         for i = 1:length(tag)
%             % Find the index in rslt corresponding to tag(i)
%             index = find(config.tagIdStruct.(tag(i))==allIds);
%             % Piece the two bytes together, masking ID bits, and convert to
%             % radians
%             response(i) = bitor(bitshift(bitand(rslt(index,1),31),8),...
%                 rslt(index,2))*pi/180;
%         end
%         disp(response*180/pi);
%     case {'GET_T_L','GET_T_R','GET_B'}
%         while true
%             fwrite(config.xbee,B0);
%             [rslt,count] = fread(config.xbee,2,'uint8');
%             if count==2, break; end
%         end
%         response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2));
%     case 'GET_A'
%         while true
%             fwrite(config.xbee,B0);
%             % rslt is data received, count is # of uint8's in rslt
%             [rslt, count] = fread(config.xbee,2,'uint8');
%             if count==2, break; end
%         end
%         % Convert angle to radians
%         response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2))*pi/180;
%     case {'GET_X','GET_Y'}
%         while true
%             fwrite(config.xbee,B0);
%             [rslt, count] = fread(config.xbee,2,'uint8');
%             if count==2, break; end
%         end
%         % Convert back to decimal
%         response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2))/100;
%     % SET instructions
%     case {'SET_X','SET_Y'}
%         % Keep 2 decimals, truncate remainder
%         data = uint16(data*100);
%         % Put most significant bit in B0
%         B0 = bitor(B0, uint8(bitshift(data,-8)));
%         % B1 is the least significant 8 bits
%         B1 = bitand(data,255);
%         while true
%             fwrite(config.xbee, B0);
%             fwrite(config.xbee, B1);
%             [~, count] = fread(config.xbee, 1, 'uint8');
%             if count, break; end
%         end
%     case 'SET_H'
%         data = uint16(data);
%         % Put most significant bit in B0
%         B0 = bitor(B0, uint8(bitshift(data,-8)));
%         % B1 is the least significant 8 bits
%         B1 = bitand(data,255);
%         while true
%             fwrite(config.xbee, B0);
%             fwrite(config.xbee, B1);
%             [~,count] = fread(config.xbee, 1, 'uint8');
%             if count, break; end
%         end
%     case {'SET_M_L','SET_M_R'}
%         % Most significant bit indicates sign of value
%         if data<0
%             B0 = bitor(B0, 1);
%         end
%         % B1 is the magnitude of the data, should be less or equal to 255
%         B1 = uint8(abs(data));
%         while true
%             fwrite(config.xbee, B0);
%             fwrite(config.xbee, B1);
%             [~,count] = fread(config.xbee, 1, 'uint8');
%             if count, break; end
%         end
%     case 'GO_F'
%         % Divide data by 10 to get centiseconds
%         data = round(data/10);
%         % Put most significant bit in B0
%         B0 = bitor(B0, uint8(bitshift(data,-8)));
%         % B1 is the least significant 8 bits
%         B1 = bitand(data,255);
%         while true
%             fwrite(config.xbee, B0);
%             fwrite(config.xbee, B1);
%             [~, count] = fread(config.xbee, 1, 'uint8');
%             if count, break; end
%         end
%     % Global with data
%     case 'G_GO_F'
%         % Divide data by 10 to get centiseconds
%         data = round(data/10);
%         % Put most significant bit in B0
%         B0 = bitor(B0, uint8(bitshift(data,-8)));
%         % B1 is the least significant 8 bits
%         B1 = bitand(data,255);
%         while true
%             fwrite(config.xbee, B0);
%             fwrite(config.xbee, B1);
%             [~, count] = fread(config.xbee, tag, 'uint8');
%             if count, break; end
%         end
% end
% 
% fclose(config.xbee);