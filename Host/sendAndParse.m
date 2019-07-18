function response = sendAndParse(serialPort, request)
%% sendAndParse
% Sends the given request on the specified serial port and parses any 
% response packets into XBeeResponse objects
%
% Parameters:
%   serialPort
%     A closed serial port instance, connected to an XBee in API = 2 mode
%   request
%     An XBeeRequest object to be transmitted
% 
% Returns:
%   response
%     An array of XBeeResponse objects

% Open XBee
fopen(serialPort);
% Send packet
fwrite(serialPort, request.toSendFormat(), 'uint8');

% TODO: Test this section to ensure closing the serial port doesn't mess up
% the reading in parse()
fclose(serialPort);
pause(0.1);
response = parse(serialPort);
