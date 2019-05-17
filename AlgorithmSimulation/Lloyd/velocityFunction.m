function deltaPosition = velocityFunction(direction, velocity)
%% velocityFunction
% Determines how much agents move, given a direction and magnitude of
% velocity over one time step
%
% Parameters:
%   direction
%     n-by-2 vector of normalized direction vectors for n agents
%   velocity
%     n-by-1 vector of magnitudes of velcoity of each agent
%
% Returns:
%   deltaPosition
%     n-by-2 vector of change in position (deltaX, deltaY) for n agents

deltaPosition = bsxfun(@times,direction,velocity(:));