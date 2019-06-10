function saveWheelConfig(path, slope, intercept, tags)
%% saveWheelConfig
% Write updated slope and intercept configs for the wheels to the XML doc
%
% Parameters:
%   path
%     Path to the config file
%   slope
%     n-by-2 matrix of slopes in [left right; left right; ... ] format,
%     where n is length of tagString
%   intercept
%     n-by-2 matrix of intercepts in [left right; left right; ... ] format,
%     where n is length of tagString
%   tags
%     Tags of the bots to update
%
% Returns:
%   N/A

config = xmlread(path);
tagNodes = config.getElementsByTagName('tag');
% For each tag
for i = 0:tagNodes.getLength-1
    tagNode = tagNodes.item(i);
    tag = char(tagNode.getTextContent());
    % If this tagNode is in the list of tags we're using
    if contains(tags, tag)
        %index = find(tags == tag);
        % Get the parent bot node
        botNode = tagNode.getParentNode();
        % Update slopes
        slopeNodes = botNode.getElementsByTagName('slope');
        leftSlopeNode = slopeNodes.item(0);
        leftSlopeNode.setTextContent(string(slope(tags == tag,1)));
        rightSlopeNode = slopeNodes.item(1);
        rightSlopeNode.setTextContent(string(slope(tags == tag,2)));
        % Update intercepts
        intNodes = botNode.getElementsByTagName('intercept');
        leftIntNode = intNodes.item(0);
        leftIntNode.setTextContent(string(intercept(tags == tag,1)));
        rightIntNode = intNodes.item(1);
        rightIntNode.setTextContent(string(intercept(tags == tag,2)));
    end
end
% Overwrite old config
xmlwrite(path,config);
