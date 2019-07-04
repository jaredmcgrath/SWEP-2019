config = parseConfig('config.xml');
config.xbee = serial('COM8','Terminator','CR', 'Timeout', 1);

sendInstruction(config, 'SET_X', 'S', 0);
sendInstruction(config, 'SET_Y', 'S', 0);
sendInstruction(config, 'SET_H', 'S', 0);
sendInstruction(config, 'SET_M_L', 'S', 110);
sendInstruction(config, 'SET_M_R', 'S', 125);

sendInstruction(config, 'GO', 'S');

N=10;

for i=1:N
    
    x(i) = sendInstruction(config, 'GET_X', 'S', 0);
    y(i) = sendInstruction(config, 'GET_Y', 'S', 0);
    theta(i) = sendInstruction(config, 'GET_A', 'S', 0);
    
end

sendInstruction(config, 'STOP', 'S');
plot(x,y,'.');
figure();
axis equal
plot(theta);