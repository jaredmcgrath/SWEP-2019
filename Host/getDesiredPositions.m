function [desiredPosition, pathIndex] = getDesiredPositions(config,...
    position, path, pathIndex)
%% getDesiredPositions
% Determines where each bot should be heading next. Maintains
% syncronization, so that all agents are on the same iteration.
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   position
%     n-by-2 vector of current positions for n agents
%   path
%     Path that agents should follow, as loaded from file
%   pathIndex
%     The current index/iteration within the path that agents are
%     attempting to reach
%
% Returns:
%   desiredPosition
%     n-by-2 vector of desired positions for n agents
%   pathIndex
%     Updated path index/iteration

desiredPosition = reshape(path(pathIndex,:),2,[])';
% Check if all agents are at their position in the path
if all(vecnorm(position-desiredPosition,2,2)<=config.maxError)
    % If so, advance agents to their next positions on the path
    pathIndex = pathIndex+1;
    % Check if the path is complete or not
    if pathIndex <= size(path,1)
        desiredPosition = reshape(path(pathIndex,:),2,[])';
    else
        % If complete, halt
        desiredPosition = position;
    end
else
    % For any bots that are close enough to their proper positions, set
    % their desired position equal to current position to halt them
    haltIndex = find(vecnorm(position-desiredPosition,2,2)<=config.maxError);
    desiredPosition(haltIndex) = position(haltIndex);
end
