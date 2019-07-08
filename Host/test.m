config = parseConfig('config.xml');
config.xbee = serial('/dev/tty.usbserial-DN01F2NX','Terminator','CR', 'Timeout', 2);

sendInstruction(config, 'SET_X', 'S', 0);
sendInstruction(config, 'SET_Y', 'S', 0);
sendInstruction(config, 'SET_H', 'S', 0);
sendInstruction(config, 'SET_M_L', 'S', 150);
sendInstruction(config, 'SET_M_R', 'S', 200);

sendInstruction(config, 'GO', 'S');

N=20;
% Data is matrix where each row is [x y theta timestamp]
for i=1:N
    data(i,:) = sendInstruction(config, 'GET_POS', 'S');
end

sendInstruction(config, 'STOP', 'S');
plot(data(:,1),data(:,2),'.');
figure();
axis equal
plot(data(:,4),data(:,3) );