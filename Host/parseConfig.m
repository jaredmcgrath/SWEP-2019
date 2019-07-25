function config = parseConfig(path)
%% parseConfig
% Parses the file supplied in path and returns all values in proper format,
% in a struct
%
% Parameters:
%   path
%     The path of the config file (usually just config.xml)
%
% Returns:
%   config
%     Struct with the following fields:
%      maxX
%       The maximum x value boundary in meters, usually 5.12
%      maxY
%       The maximum y value boundary in meters, usually 5.12
%      maxError
%        Maximum allowable error when considering if an agent has reached a
%        desired location
%      rChassis
%        Radius of the robot's chassis
%      rWheel
%        Radius of the robot's wheel
%      validTags
%       A string, where each character is that of one bot
%      tagIdStruct
%       A struct containing the numerical ID of each bot corresponding to
%       their character tag
%      insStruct
%       A struct containing the numerical value of each instruction
%       corresponding to the string value
%      slope
%       n-by-2 matrix of slopes in [left right; left right; ... ] format,
%       where n is length of allTags
%      intercept
%       n-by-2 matrix of intercepts in [left right; left right; ... ] format,
%       where n is length of allTags
%      beacons
%       Extra beacons for RSSI pings

configDOM = xmlread(path);
% Get maxX
maxXNode = configDOM.getElementsByTagName('maxX');
maxXNode = maxXNode.item(0);
maxX = str2double(maxXNode.getTextContent());

% Get maxY
maxYNode = configDOM.getElementsByTagName('maxY');
maxYNode = maxYNode.item(0);
maxY = str2double(maxYNode.getTextContent());

% Get maxError
maxErrNode = configDOM.getElementsByTagName('maxError');
maxErrNode = maxErrNode.item(0);
maxError = str2double(maxErrNode.getTextContent());

% Get rChassis
rChassisNode = configDOM.getElementsByTagName('chassisRadius');
rChassisNode = rChassisNode.item(0);
rChassis = str2double(rChassisNode.getTextContent());

% Get rWheel
rWheelNode = configDOM.getElementsByTagName('wheelRadius');
rWheelNode = rWheelNode.item(0);
rWheel = str2double(rWheelNode.getTextContent());

% Get bot tags/ids
tagNodes = configDOM.getElementsByTagName('bot');
validTags = char();
tagAddressStruct = struct();
for i = 0:tagNodes.getLength-1
    bot = tagNodes.item(i);
    tag = bot.getElementsByTagName('tag');
    tag = tag.item(0);
    tag = char(tag.getTextContent());
    validTags = [validTags tag];
    id = bot.getElementsByTagName('address');
    id = id.item(0);
    id = uint8(str2double(id.getTextContent()));
    tagAddressStruct.(tag) = id;
end

% Get instructions
insNodes = configDOM.getElementsByTagName('instruction');
insStruct = struct();
for i = 0:insNodes.getLength-1
    ins = insNodes.item(i);
    name = ins.getElementsByTagName('name');
    name = name.item(0);
    name = string(name.getTextContent());
    value = ins.getElementsByTagName('value');
    value = value.item(0);
    value = str2double(value.getTextContent());
    insStruct.(name) = value;
end

% Get wheels params
slope = zeros(length(validTags), 2);
intercept = zeros(length(validTags), 2);
% Left wheels
leftNodes = configDOM.getElementsByTagName('leftWheel');
for i = 0:leftNodes.getLength-1
    wheel = leftNodes.item(i);
    % The slope node for this wheel
    s = wheel.getElementsByTagName('slope');
    s = s.item(0);
    s = str2double(s.getTextContent());
    slope(i+1, 1) = s;
    % The intercept node for this wheel
    in = wheel.getElementsByTagName('intercept');
    in = in.item(0);
    in = str2double(in.getTextContent());
    intercept(i+1, 1) = in;
end
% Right wheels
rightNodes = configDOM.getElementsByTagName('rightWheel');
for i = 0:rightNodes.getLength-1
    wheel = rightNodes.item(i);
    % The slope node for this wheel
    s = wheel.getElementsByTagName('slope');
    s = s.item(0);
    s = str2double(s.getTextContent());
    slope(i+1, 2) = s;
    % The intercept node for this wheel
    in = wheel.getElementsByTagName('intercept');
    in = in.item(0);
    in = str2double(in.getTextContent());
    intercept(i+1, 2) = in;
end

% Beacons
beaconNodes = configDOM.getElementsByTagName('beacon');
for i = 0:beaconNodes.getLength-1
    beacon = beaconNodes.item(i);
    % The serial port of the beacon
    port = beacon.getElementsByTagName('port');
    port = port.item(0);
    port = string(port.getTextContent());
    beacons(i+1) = serial(port,'Terminator','', 'Timeout', 1);
    x = beacon.getElementsByTagName('x');
    x = x.item(0);
    x = str2double(x.getTextContent());
    y = beacon.getElementsByTagName('y');
    y = y.item(0);
    y = str2double(y.getTextContent());
    beaconPositions(i+1,:) = [x y];
end

% Put all values into a struct
config = struct('maxX',maxX,'maxY',maxY,'maxError',maxError,'validTags',...
    validTags,'tagAddressStruct',tagAddressStruct,'insStruct',insStruct,'slope',...
    slope,'intercept',intercept,'rChassis',rChassis,'rWheel',rWheel,...
    'beacons',beacons,'beaconPositions',beaconPositions);
