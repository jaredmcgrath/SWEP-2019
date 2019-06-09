function [e] = AdjustPosition(XbeeSerial, botTags, currentPosition, desiredPosition, index, error, leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept)
%Uses control theory to determine how to drive the robot motors in order to
%get the robots from their current positions to their desired positions
fopen(XbeeSerial);


for i = 1:length(botTags)
    
    %does this need fixing?
    if(currentPosition(i,1) > desiredPosition(i,1) - 0.1 && currentPosition(i,2) > desiredPosition(i,2) - 0.1 && currentPosition(i,1) < desiredPosition(i,1) + 0.1 && currentPosition(i,2) < desiredPosition(i,2) + 0.1)
        leftWheel = 0;
        rightWheel = 0;
        e = [0; 0; 0];
    else
        %for each robot, get the inputs for the each wheel to get to the
        %desired position
        [leftWheel, rightWheel, e] = Control(currentPosition(i,:), desiredPosition(i,:), index, error, leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept);
        disp(leftWheel);
        disp(rightWheel);
    end
    
    %determine the sign character for the wheel
    if(sign(leftWheel) == -1)
        signLeft = 'N';
    else
        signLeft ='P';
    end
    
    %turn the wheel value into a string
    if(abs(leftWheel) < 10)
        leftWheelString = ['00',num2str(abs(leftWheel))];
    elseif(abs(leftWheel) < 100)
        leftWheelString = ['0',num2str(abs(leftWheel))];
    elseif(abs(leftWheel) < 1000)
        leftWheelString = num2str(abs(leftWheel));
    else
        leftWheelString = '000';
    end
    stringLeft = ['B', signLeft, leftWheelString];
    
    %determine the sign character for the wheel
    if(sign(rightWheel) == -1)
        signRight = 'N';
    else
        signRight ='P';
    end
    
    %turn the wheel value into a string
    if(abs(rightWheel) < 10)
        rightWheelString = ['00',num2str(abs(rightWheel))];
    elseif(abs(rightWheel) < 100)
        rightWheelString = ['0',num2str(abs(rightWheel))];
    elseif(abs(rightWheel) < 1000)
        rightWheelString = num2str(abs(rightWheel));
    else
        rightWheelString = '000';
    end
    stringRight = ['A', signRight, rightWheelString];
    
    while(true)
        %send the agent tag to the robots to prepar the correct robot to
        %receive its inputs, poll until the tag gets sent back
        pause(0.02);
        fwrite(XbeeSerial,botTags(i));
        receivedSig = fread(XbeeSerial,1);
        disp("here 1");
        if (receivedSig == botTags(i))
            while(true)
                %once the tag is sent back, send B leftinput A rightinput
                %until the response to rpi character ('K') is sent back
                fwrite(XbeeSerial, stringLeft);
                pause(0.002);
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
end

fclose(XbeeSerial);
end

