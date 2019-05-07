% Handles host -> bot communication
function response = sendInstruction(xbeeSerial, instruction, botTag, data)
%% sendInstruction
% Translates an instruction to proper format as per the communication
% protocol, then transmits that command
% TODO: Write docs
% TODO: Change G_CONF behaviour to something responsive/useful
% This is a constant structure that reflects tag-ID and instruction values
% TODO: Add to config file later

tagId = struct('S',0,'E',1,'L',2);
insHex = struct('GO',0,'GET_X',1,'GET_Y',2,'GET_A',3,'GET_T_L',4,'GET_T_R',...
    5,'GET_B',6,'STOP',7,'SET_X',18,'SET_Y',20,'SET_H',22,'SET_M_L',24,...
    'SET_M_R',26,'G_GO',224,'G_RESET',225,'G_CONF',226);

% If its a global command, nargin = 2, so set bot=0
if nargin==2
    id = 0;
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
    case 'G_CONF'
        fwrite(xbeeSerial,B0);
        % Wait until 3 responses have been recevied
        disp(fread(xbeeSerial,3,'uint8'));
    % Instructions that require a response
    case {'GET_A','GET_T_L','GET_T_R','GET_B'}
        fwrite(xbeeSerial,B0);
        rslt = fread(xbeeSerial,2,'uint8');
        response = bitor(bitshift(rslt(1),8),rslt(2));
    case {'GET_X','GET_Y'}
        fwrite(xbeeSerial,B0);
        rslt = fread(xbeeSerial,2,'uint8');
        response = bitor(bitshift(rslt(1),8),rslt(2))/100;
    % 2 byte instructions
    % x, y are specified as floats between 0 and 5.12
    % Transmit as 0 to 512
    case {'SET_X','SET_Y'}
        data = uint16(data*100);
        B0 = bitor(B0, uint8(bitshift(data,-8)));
        B1 = bitand(data,255);
        fwrite(xbeeSerial, B0);
        fwrite(xbeeSerial, B1);
    % Heading should be angle in degrees
    case 'SET_H'
        data = uint16(data);
        B0 = bitor(B0, uint8(bitshift(data,-8)));
        B1 = bitand(data,255);
        fwrite(xbeeSerial, B0);
        fwrite(xbeeSerial, B1);
    case {'SET_M_L','SET_M_R'}
        if data<0
            B0 = bitor(B0, 1);
        end
        B1 = uint8(data);
        fwrite(xbeeSerial, B0);
        fwrite(xbeeSerial, B1);
end
fclose(xbeeSerial);