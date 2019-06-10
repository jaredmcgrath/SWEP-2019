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
    % 1 byte instructions, no response
    case {'GO','STOP','G_GO','G_RESET'}
        fwrite(config.xbee,B0);
    case 'G_CONF'
        fwrite(config.xbee,B0);
        % Wait until all bots have responded
        disp(fread(config.xbee,tag,'uint8'));
    % Instructions that require a response
    case {'GET_T_L','GET_T_R','GET_B'}
        fwrite(config.xbee,B0);
        rslt = fread(config.xbee,2,'uint8');
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2));
    case 'GET_A'
        fwrite(config.xbee,B0);
        rslt = fread(config.xbee,2,'uint8');
        % Convert angle to radians
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2))*pi/180;
    case {'GET_X','GET_Y'}
        fwrite(config.xbee,B0);
        rslt = fread(config.xbee,2,'uint8');
        % Convert back to decimal
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2))/100;
    % 2 byte instructions, no response
    case {'SET_X','SET_Y'}
        % Keep 2 decimals, truncate remainder
        data = uint16(data*100);
        % Put most significant bit in B0
        B0 = bitor(B0, uint8(bitshift(data,-8)));
        % B1 is the least significant 8 bits
        B1 = bitand(data,255);
        fwrite(config.xbee, B0);
        fwrite(config.xbee, B1);
    case 'SET_H'
        data = uint16(data);
        % Put most significant bit in B0
        B0 = bitor(B0, uint8(bitshift(data,-8)));
        % B1 is the least significant 8 bits
        B1 = bitand(data,255);
        fwrite(config.xbee, B0);
        fwrite(config.xbee, B1);
    case {'SET_M_L','SET_M_R'}
        % Most significant bit indicates sign of value
        if data<0
            B0 = bitor(B0, 1);
        end
        % B1 is the magnitude of the data, should be less or equal to 255
        B1 = uint8(data);
        fwrite(config.xbee, B0);
        fwrite(config.xbee, B1);
end
fclose(config.xbee);