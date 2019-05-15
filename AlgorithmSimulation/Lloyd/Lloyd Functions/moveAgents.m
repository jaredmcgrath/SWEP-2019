function [agentPositions, distanceTravelled, energy] = moveAgents(agentPositions,...
    centroids, energy, velocityType, maxVelocity, scaleFactor)
%% moveAgents
% Moves each agent towards its assigned centroid
% 
% Parameters:
%   agentPositions
%     n-by-2 vector of the x, y positions for n agents before moving
%   centroids
%     n-by-2 vector of the x, y centroid locations that agents move towards
%   energy
%     n-by-1 vector of agent energy before moving
%   velocityType
%     Either "Constant Velocity" or "Proportional Velocity" as determined
%     in the GUI
%   maxVelocity
%     If velocityType = "Constant Velocity", this is the constant velocity
%     Otherwise, this is the maximum velocity at which agents can travel
%   scaleFactor
%     Used for "Proportional Velocity". Velocity is proportional to 
%     distance between agent and centroid, scaled by the scale factor
%
% Returns:
%   agentPositions
%     n-by-2 vector of x, y positions of for the n agents after moving
%   distanceTravelled
%     n-by-1 vector of distance travelled by each agent this iteration
%   energy
%     n-by-1 vector of agent energy after moving

% Agents move towards centroids
direction = centroids - agentPositions;
% Calculate the 2-norm of direction accross rows
magnitude = vecnorm(direction,2,2);
% Scale directions by the corresponding magnitudes
direction = bsxfun(@rdivide,direction,magnitude(:));
% Filter any NaN directions to 0
direction(isnan(direction)) = 0;
% Determine magnitudes of velocities
if strcmp(velocityType, 'Constant Velocity')
    velocity = maxVelocity;
else
    velocity = magnitude*scaleFactor;
    % Filter any velocities > maxVelocity
    velocity(velocity>maxVelocity) = maxVelocity;
    % Filter any NaN velocities to 0
    velocity(isnan(velocity)) = 0;
end
% Get the change in position from velocityFunction
deltaPosition = velocityFunction(direction, velocity);
% Update agentPositions
agentPositions = agentPositions + deltaPosition;
% Get the change in energy from energyFunction
deltaEnergy = energyFunction(velocity, deltaPosition);
% Update energy
energy = energy + deltaEnergy;
% Calculate the norm of changes in position and sum to get net distance
distanceTravelled = sum(vecnorm(deltaPosition,2,2));
