function [botTags, botTagsLower] = initializeXbee(XbeeSerial, ...
    botPositionArray, botTagString)
%% initializeXbee
% TODO: Write docs
%%
% Open for binary writing
fopen(XbeeSerial);

%converts any input for x, y, and theta into an acceptable value so that
%robots can receive them accurately
if(length(thetaTemp) > 3)
    thetaInit(1,:) = '000';
elseif(length(thetaTemp) == 3)
    thetaInit(1,:) = thetaTemp; 
elseif(length(thetaTemp) == 2)
    thetaInit(1,2:3) = thetaTemp; 
    thetaInit(1,1) = '0';
elseif(length(thetaTemp) == 1)   
    thetaInit(1,3) = thetaTemp; 
    thetaInit(1,1:2) = '00';
else
    thetaInit(1,:) = '000';
end
    
    
for i = 1:length(botTags)
    xString = ['Input the initial X-coordinate for robot ', botTags(i), '. (metres, 2 decimal places) '];
    yString = ['Input the initial Y-coordinate for robot ', botTags(i), '. (metres, 2 decimal places) '];
    
    xTemp = input(xString, 's');
    yTemp = input(yString, 's');
    
    if(length(xTemp) > 4)
        xInit(i,:) = '0.00';
    elseif(length(xTemp) == 3)
        xInit(i,1:3) = xTemp; 
        xInit(i,4) = '0';
    elseif(length(xTemp) == 2)
        xInit(i,1:2) = xTemp; 
        xInit(i,3:4) = '00';
    elseif(length(xTemp) == 1)   
        xInit(i,1) = xTemp; 
        xInit(i,2:4) = '.00';
    else
        xInit(i,:) = xTemp;
    end
      
    if(length(yTemp) > 4)
        yInit(i,:) = '0.00';
    elseif(length(yTemp) == 3)
        yInit(i,1:3) = yTemp; 
        yInit(i,4) = '0';
    elseif(length(yTemp) == 2)
        yInit(i,1:2) = yTemp; 
        yInit(i,3:4) = '00';
    elseif(length(yTemp) == 1)   
        yInit(i,1) = yTemp; 
        yInit(i,2:4) = '.00';
    else
        yInit(i,:) = yTemp;
    end
end

%send the data to each robot as a string of x,y,theta: 0.00 0.00 000 (no
%spaces)
for i = 1:length(botTags)
    initString = [xInit(i,:), yInit(i,:), thetaInit];
    while(true)
        pause(0.02);
        fwrite(XbeeSerial,botTags(i));
        receivedSig = char(fread(XbeeSerial,1));
        if (receivedSig == botTags(i))
           while(true)
               %once the tag is sent back, send the x & y initial position
               %until the response to rpi character ('K') is sent back
               fwrite(XbeeSerial, initString);
               pause(0.02);
               check = fread(XbeeSerial,1);
               if (check == 'K')
                   break;
               end
           end
           string = ['Agent ', botTags(i), ' is ready.'];
           disp(string);
           break;
        end
    end
end
botTagsLower = char(botTags + 32); %converts the capital tags to lower case tags

fclose(XbeeSerial);