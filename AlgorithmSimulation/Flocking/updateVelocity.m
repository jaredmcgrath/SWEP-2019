function agentVelocity = updateVelocity(L, timeStep, agentVelocity)
%% updateVelocity
% Updates the velocity of each agent using the Laplacian matrix
%
% Parameters:
%   L
%     Laplacian matrix
%   timeStep
%     Assumed time step between each iteration
%   agentVelocity
%     n-by-2 matrix of n agent velocities in [x1 y1; x2 y2; ...] format,
%     before update
%
% Returns:
%   agentVelocity
%     n-by-2 matrix of n agent velocities in [x1 y1; x2 y2; ...] format,
%     after update

agentVelocity = agentVelocity - timeStep*L*agentVelocity;
