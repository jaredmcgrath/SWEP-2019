function [maxX, maxY, validBotString, botTagId, instructionVal, wheels] =...
    parseConfig(path)
%% parseConfig
% Parses the file supplied in path and returns all values in proper format
%
% Parameters:
%   path
%     The path of the config file (usually just config.xml)
%
% Returns:
%   maxX
%     The maximum x value boundary in meters, usually 5.12
%   maxY
%     The maximum y value boundary in meters, usually 5.12
%   validBotString
%     A string, where each character is that of one bot
%   botTagId
%     A struct containing the numerical ID of each bot corresponding to
%     their character tag
%   instructionVal
%     A struct containing the numerical value of each instruction
%     corresponding to the string value
%   wheels
%     An n-by-2 matrix containing slope and intercept for each of the n
%     bots

config = xmlread(path);
maxXNodes = config.getElementsByTagName('maxX');
maxXNode = maxXNodes.item(0);
maxX = str2double(maxXNode.getFirstChild.getData);

maxYNodes = config.getElementsByTagName('maxY');
maxYNode = maxYNodes.item(0);
maxY = str2double(maxYNode.getFirstChild.getData);

tagNodes = config.getElementsByTagName('bot');
validBotString = char();
botTagId = struct();
for i = 0:tagNodes.getLength-1
    bot = tagNodes.item(i);
    tag = bot.getElementsByTagName('tag');
    tag = tag.item(0);
    tag = char(tag.getFirstChild.getData);
    validBotString = [validBotString tag];
    id = bot.getElementsByTagName('value');
    id = id.item(0);
    id = int8(str2double(id.getFirstChild.getData));
    botTagId.(tag) = id;
end

insNodes = config.getElementsByTagName('instruction');
instructionVal = struct();
for i = 0:insNodes.getLength-1
    ins = insNodes.item(i);
    name = ins.getElementsByTagName('name');
    name = name.item(0);
    name = string(name.getFirstChild.getData);
    value = ins.getElementsByTagName('value');
    value = value.item(0);
    value = str2double(value.getFirstChild.getData);
    instructionVal.(name) = value;
end
disp('test')