function response = sendInstruction(config, instruction, tag, data)
%% sendInstruction
% Translates a text instruction to proper format specified in communication
% protocol. Transmits that command and waits for a response, if applicable.
% To understand instruction/data formats, consult the spreadsheet.
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

% If its a global command, set id = 7 (all bots)
if contains(instruction,'G_')
    id = 7;
else
    id = config.tagIdStruct.(tag);
end

% Generate ID-instruction part of B0
B0 = bitor(bitshift(uint8(id),5), uint8(config.insStruct.(instruction)));
fopen(config.xbee);
switch instruction
    % All instructions are sent, and then wait for a response
    % If no response received, resend instruction
    case {'GO','STOP'}
        while true
            fwrite(config.xbee,B0);
            [~, count] = fread(config.xbee,1,'uint8');
            if count, break; end
        end
    case {'G_CONF','G_GO','G_RESET'}
        while true
            fwrite(config.xbee,B0);
            [~, count] = fread(config.xbee,tag,'uint8');
            if count==tag, break; end
        end
    % GET instructions
    case {'GET_T_L','GET_T_R','GET_B'}
        while true
            fwrite(config.xbee,B0);
            [rslt,count] = fread(config.xbee,2,'uint8');
            if count==2, break; end
        end
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2));
    case 'GET_A'
        while true
            fwrite(config.xbee,B0);
            % rslt is data received, count is # of uint8's in rslt
            [rslt, count] = fread(config.xbee,2,'uint8');
            if count==2, break; end
        end
        % Convert angle to radians
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2))*pi/180;
    case {'GET_X','GET_Y'}
        while true
            fwrite(config.xbee,B0);
            [rslt, count] = fread(config.xbee,2,'uint8');
            if count==2, break; end
        end
        % Convert back to decimal
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2))/100;
    % SET instructions
    case {'SET_X','SET_Y'}
        % Keep 2 decimals, truncate remainder
        data = uint16(data*100);
        % Put most significant bit in B0
        B0 = bitor(B0, uint8(bitshift(data,-8)));
        % B1 is the least significant 8 bits
        B1 = bitand(data,255);
        while true
            fwrite(config.xbee, B0);
            fwrite(config.xbee, B1);
            [~, count] = fread(config.xbee, 1, 'uint8');
            if count, break; end
        end
    case 'SET_H'
        data = uint16(data);
        % Put most significant bit in B0
        B0 = bitor(B0, uint8(bitshift(data,-8)));
        % B1 is the least significant 8 bits
        B1 = bitand(data,255);
        while true
            fwrite(config.xbee, B0);
            fwrite(config.xbee, B1);
            [~,count] = fread(config.xbee, 1, 'uint8');
            if count, break; end
        end
    case {'SET_M_L','SET_M_R'}
        % Most significant bit indicates sign of value
        if data<0
            B0 = bitor(B0, 1);
        end
        % B1 is the magnitude of the data, should be less or equal to 255
        B1 = uint8(data);
        while true
            fwrite(config.xbee, B0);
            fwrite(config.xbee, B1);
            [~,count] = fread(config.xbee, 1, 'uint8');
            if count, break; end
        end
end

fclose(config.xbee);