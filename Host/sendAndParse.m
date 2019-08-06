function response = sendAndParse(serialPort, request, isOpen, shouldClose)
%% sendAndParse
% Sends the given request on the specified serial port and parses any 
% response packets into XBeeResponse objects
%
% Parameters:
%   serialPort
%     A serial port instance, connected to an XBee in API = 2 mode
%   request
%     An XBeeRequest object to be transmitted
%   isOpen
%     Boolean value indicating whether the serialPort is open
%   shouldClose
%     Boolean value indicating whether the serialPort should be closed upon
%     returning
% 
% Returns:
%   response
%     An array of XBeeResponse objects

% Open XBee
if nargin < 3 || ~isOpen
    fopen(serialPort);
end
% Send packet
fwrite(serialPort, request.toSendFormat(), 'uint8');
pause(0.1);

response = parse(serialPort);

% Close the serial port
if nargin < 4 || shouldClose
    fclose(serialPort);
end
