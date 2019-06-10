function [] = Robot(tag, direction, XbeeSerial)
%Sends the direction to all bots through the Xbees, using the tag for which
%bot the instruction is meant for, to wait until that specific bot has
%responded
%    tag is a char variable that represents which bot the direction, which
%    is also a char, is for
while(true)
    pause(0.02);
    write(XbeeSerial, tag);
    botTag = char(read(XbeeSerial,1));
    if (botTag == tag)
      break;
    end
end

while(true)
    pause(0.02);
    write(XbeeSerial, direction);
    botConfirm = char(read(XbeeSerial,1));
    if (botConfirm == 'K')
        break;
    end
end

string = ['Agent ', tag, ' has received its instruction.'];
disp(string);
end

