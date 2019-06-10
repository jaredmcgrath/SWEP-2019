close all
clear
clc

rpi = raspi('130.15.101.192','pi','swep2017');
XbeeSerial = serialdev(rpi,'/dev/ttyUSB0',9600); %define the serial port and set the BAUD rate
rpiSerial = serialdev(rpi,'/dev/ttyAMA0');

[bots, botsLower] = Setup(XbeeSerial);


disp("Write w, a, s, or d to direct the robots. Input n for no movement");
while(true)
    exit = input('Exit program?', 's');
    if (exit == 'y' || exit == 'Y')
        break;
    end
    
    bot_dir = zeros(length(bots));
    for i = 1:length(bots)
        string = ['Input direction for robot ', bots(i), '.'];
        bot_dir(i) = input(string, 's');
    end
   
    for i = 1:length(bots)
        if (bot_dir(i) ~= 'w' && bot_dir(i) ~= 'a' && bot_dir(i) ~= 's' && bot_dir(i) ~= 'd' && bot_dir(i) ~= 'n')
            string = ['Incorrect input for robot ', bots(i), '.'];
            disp(string);
        else
            Robot(bots(i), bot_dir(i),XbeeSerial);
        end
    end
end
  