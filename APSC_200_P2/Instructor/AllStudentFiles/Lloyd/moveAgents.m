function [agentPositions, distanceTravelled, energy] = moveAgents(agentPositions,...
    centroids, sides, energy, velocityType, maxVelocity, scaleFactor)
%% moveAgents
% Moves each agent towards its assigned centroid. Must ensure agents don't
% move out of bounds.
% 
% Parameters:
%   agentPositions
%     n-by-2 vector of the x, y positions for n agents before moving
%   centroids
%     n-by-2 vector of the x, y centroid locations that agents move towards
%   sides
%     Side length of the arena
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
%% Your Code Below
