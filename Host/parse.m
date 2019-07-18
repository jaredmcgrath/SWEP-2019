function response = parse(serialPort)
%% parse
% Parses any data available on the given serial port into XBeeResponse
% objects
%
% Parameters:
%   serialPort
%     The closed serial port representing the XBee that is to be parsed
%
% Returns:
%   response
%     Array of XBeeResponse objects

% Open the serial port
fopen(serialPort);

% Initialize response. Should be an array of XBeeResponse objects
response = XBeeResponse();
checksumTotal = 0;
escape = false;

% Internal counter to keep track of where we are within a given packet
pos = 1;
while serialPort.BytesAvailable > 0
    % Read a byte. Make sure response is uint8
    b = fread(serialPort, 1, 'uint8');
    
    % If we receive an unexpected start byte
    if pos > 1 && b == XBeeConst.START_BYTE
        warning(strcat("Unexpected start byte. Packet ", ...
            num2str(length(response)), " is invalid"));
        % Re-init the response instance
        response(end+1) = XBeeResponse();
        % Reset internal counter
        pos = 1;
        checksumTotal = 0;
        escape = false;
    % If we receive an escape byte
    elseif pos > 1 && b == XBeeConst.ESCAPE
        % Indicate next byte is escaped, and skip the rest of loop
        escape = true;
        continue;
    elseif escape
        % Apply escape operation, XOR(data,0x20)
        b = bitxor(b,32);
        escape = false;
    end
    
    % If we're looking at the API ID or later
    if pos >= XBeeConst.API_ID_INDEX
        % Stupid matlab doesn't allow uint overflow...
        checksumTotal = mod(checksumTotal + uint16(b),256);
    end
    
    switch pos
        % Should be the start byte
        case 1
            if b == XBeeConst.START_BYTE
                pos = pos + 1;
            else
                warning("Expected start byte not received");
            end
            
        % Should be the length MSB
        case 2
            response(end).msbLength = b;
            pos = pos + 1;
            
        % Should be the length LSB
        case 3
            response(end).lsbLength = b;
            pos = pos + 1;
            
        % Should be the API ID
        case 4
            response(end).apiId = b;
            pos = pos + 1;
        
        % This should be the api specific frame data or checksum
        otherwise
            % Check if this should be the last byte in this transmission
            % Packet length doesn't include start, length, or checksum, and
            % indexes start at 1 so add 4
            if pos == response(end).packetLength + 4
                % Check checksum
                if bitand(uint8(checksumTotal), 255) == 255
                    % Set the checksum
                    response(end).checksum = b;
                    response(end).isValid = true;
                    
                    % Initialize new XBeeResponse if not done parsing
                    % IMPORTANT: If this clause is false, the loop *should*
                    % end. If it doesn't data is going to be messed up
                    if serialPort.BytesAvailable > 0
                        response(end+1) = XBeeResponse();
                        pos = 1;
                        checksumTotal = 0;
                        escape = false;
                    end
                else
                    % Invalid packet
                    warning("Invalid packet");
                end
            % If not at end, append frame data
            else
                response(end).frameData(end+1) = b;
                pos = pos + 1;
            end
    end
end

% Close the serial port
fclose(serialPort);
