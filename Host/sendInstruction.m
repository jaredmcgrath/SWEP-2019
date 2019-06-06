function response = sendInstruction(xbeeSerial, numBots, instruction, botTag, data)
%% sendInstruction
% Translates a text instruction to proper format specified in communication
% protocol. Transmits that command and waits for a response, if applicable.
% To understand instruction/data formats, consult the spreadsheet.
%
% Parameters:
%   xbeeSerial
%     Serial port object for the XBee. The serial port should be closed
%     upon calling sendInstruction
%   numBots
%     Number of total bots in use
%   instruction
%     String instruction. Must match one of the instructions in the
%     communication protocol
%   botTag (optional)
%     If the instruction is specific to a bot, botTag should be the single
%     character tag of that bot
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

% This is a constant structure that reflects tag-ID and instruction values
% TODO: Add to config file later
tagId = struct('S',0,'E',1,'L',2);
insHex = struct('GO',0,'GET_X',1,'GET_Y',2,'GET_A',3,'GET_T_L',4,'GET_T_R',...
    5,'GET_B',6,'STOP',7,'SET_X',18,'SET_Y',20,'SET_H',22,'SET_M_L',24,...
    'SET_M_R',26,'G_GO',224,'G_RESET',225,'G_CONF',226);

% If its a global command, nargin = 3, so set bot=7 (all bots)
if nargin==3
    id = 7;
else
    id = getfield(tagId, botTag);
end
% Generate ID-instruction part of B0
B0 = bitor(bitshift(uint8(id),5), uint8(getfield(insHex,instruction)));
fopen(xbeeSerial);
switch instruction
    % 1 byte instructions, no response
    case {'GO','STOP','G_GO','G_RESET'}
        fwrite(xbeeSerial,B0);
    % TODO: Change G_CONF behaviour to something responsive/useful
    case 'G_CONF'
        fwrite(xbeeSerial,B0);
        % Wait until numBots responses have been recevied
        disp(fread(xbeeSerial,numBots,'uint8'));
    % Instructions that require a response
    case {'GET_T_L','GET_T_R','GET_B'}
        fwrite(xbeeSerial,B0);
        rslt = fread(xbeeSerial,2,'uint8');
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2));
    case 'GET_A'
        fwrite(xbeeSerial,B0);
        rslt = fread(xbeeSerial,2,'uint8');
        % Convert angle to radians
        response = bitor(bitshift(bitand(rslt(1),31),8),rslt(2))*pi/180;
    case {'GET_X','GET_Y'}
        fwrite(xbeeSerial,B0);
        rslt = fread(xbeeSerial,2,'uint8');
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
        fwrite(xbeeSerial, B0);
        fwrite(xbeeSerial, B1);
    case 'SET_H'
        data = uint16(data);
        % Put most significant bit in B0
        B0 = bitor(B0, uint8(bitshift(data,-8)));
        % B1 is the least significant 8 bits
        B1 = bitand(data,255);
        fwrite(xbeeSerial, B0);
        fwrite(xbeeSerial, B1);
    case {'SET_M_L','SET_M_R'}
        % Most significant bit indicates sign of value
        if data<0
            B0 = bitor(B0, 1);
        end
        % B1 is the magnitude of the data, should be less or equal to 255
        B1 = uint8(data);
        fwrite(xbeeSerial, B0);
        fwrite(xbeeSerial, B1);
end
fclose(xbeeSerial);