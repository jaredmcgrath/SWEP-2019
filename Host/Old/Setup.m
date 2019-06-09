function [botTags, botTagsLower] = Setup(XbeeSerial)
%Checks all bots to ensure that they are setup, it takes in a variable
%amount of robots, represented by the botTags array
botTags = input('Input the tags of all agents that will be used in capitals with no spaces (Ex = SEL).', 's');
for i = 1:length(botTags)
    while(true)
        pause(0.02);
        write(XbeeSerial,botTags(i));
        receivedSig = read(XbeeSerial,1);
        if (receivedSig == botTags(i))
           string = ['Agent ', botTags(i), ' is ready.'];
           disp(string);
           break;
        end
    end
end
botTagsLower = char(botTags + 32); %converts the capital tags to lower case tags

