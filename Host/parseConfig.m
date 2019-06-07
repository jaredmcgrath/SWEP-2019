function [maxX, maxY, allTags, botTagId, instructionVal, slope, ...
    intercept] = parseConfig(path)
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
%   slope
%     n-by-2 matrix of slopes in [left right; left right; ... ] format,
%     where n is length of allTags
%   intercept
%     n-by-2 matrix of intercepts in [left right; left right; ... ] format,
%     where n is length of allTags

config = xmlread(path);
% Get maxX
maxXNode = config.getElementsByTagName('maxX');
maxXNode = maxXNode.item(0);
maxX = str2double(maxXNode.getFirstChild.getData);

% Get maxY
maxYNode = config.getElementsByTagName('maxY');
maxYNode = maxYNode.item(0);
maxY = str2double(maxYNode.getFirstChild.getData);

% Get bot tags/ids
tagNodes = config.getElementsByTagName('bot');
allTags = char();
botTagId = struct();
for i = 0:tagNodes.getLength-1
    bot = tagNodes.item(i);
    tag = bot.getElementsByTagName('tag');
    tag = tag.item(0);
    tag = char(tag.getFirstChild.getData);
    allTags = [allTags tag];
    id = bot.getElementsByTagName('value');
    id = id.item(0);
    id = int8(str2double(id.getFirstChild.getData));
    botTagId.(tag) = id;
end

% Get instructions
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

% Get wheels params
slope = zeros(length(allTags), 2);
intercept = zeros(length(allTags), 2);
% Left wheels
leftNodes = config.getElementsByTagName('leftWheel');
for i = 0:leftNodes.getLength-1
    wheel = leftNodes.item(i);
    % The slope node for this wheel
    s = wheel.getElementsByTagName('slope');
    s = s.item(0);
    s = str2double(s.getFirstChild.getData);
    slope(i+1, 1) = s;
    % The intercept node for this wheel
    in = wheel.getElementsByTagName('intercept');
    in = in.item(0);
    in = str2double(in.getFirstChild.getData);
    intercept(i+1, 1) = in;
end
% Right wheels
rightNodes = config.getElementsByTagName('rightWheel');
for i = 0:rightNodes.getLength-1
    wheel = rightNodes.item(i);
    % The slope node for this wheel
    s = wheel.getElementsByTagName('slope');
    s = s.item(0);
    s = str2double(s.getFirstChild.getData);
    slope(i+1, 2) = s;
    % The intercept node for this wheel
    in = wheel.getElementsByTagName('intercept');
    in = in.item(0);
    in = str2double(in.getFirstChild.getData);
    intercept(i+1, 2) = in;
end
