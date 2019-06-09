function [] = ManualWheelSet(XbeeSerial, botTag, leftWheel, rightWheel)
% Set up the Xbee connection
%XbeeSerial = serial('COM7','Terminator','CR', 'Timeout', 2);

% Call the Setup function with the Xbee object to set up all robots, it will
% take user input for all robot tags for robots in use
%[bots, botTagLower] = SetupXbee(XbeeSerial);

%sets the speeds of the wheels with manual inputs
if(leftWheel > 99)
    leftWheel = int2str(leftWheel);
elseif(leftWheel > 9)
    leftWheel = ['0', int2str(leftWheel)];
else
    leftWheel = ['00', int2str(leftWheel)];   
end

if(rightWheel > 99)
    rightWheel = int2str(rightWheel);
elseif(rightWheel > 9)
    rightWheel = ['0', int2str(rightWheel)];
else
    rightWheel = ['00', int2str(rightWheel)];   
end

stringLeft = ['B', 'P', leftWheel];
stringRight = ['A', 'P', rightWheel];

fopen(XbeeSerial);
while(true)
    %send the agent tag to the robots to prepar the correct robot to
    %receive its inputs, poll until the tag gets sent back
    pause(0.02);
    fwrite(XbeeSerial,botTag);
    receivedSig = fread(XbeeSerial,1);
    disp("here 1");
    if (receivedSig == botTag)
        while(true)
            %once the tag is sent back, send B leftinput A rightinput
            %until the response to rpi character ('K') is sent back
            fwrite(XbeeSerial, stringLeft);
            pause(0.02);
            check = fread(XbeeSerial,1);
            disp("here 2");
            if (check == 'K')
                break;
            end
        end

        while(true)
            fwrite(XbeeSerial, stringRight);
            pause(0.02);
            check = fread(XbeeSerial,1);
            disp("here 3");
            if (check == 'K')
                break;
            end
        end
        break;
    end
end

fwrite(XbeeSerial, '9');

fclose(XbeeSerial);
end


