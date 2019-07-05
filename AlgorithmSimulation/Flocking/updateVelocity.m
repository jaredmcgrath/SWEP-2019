function agentVelocity = updateVelocity(L, dt, agentVelocity)
%% updateVelocity
% Updates the velocity of each agent using dynamics governed by the
% Laplacian matrix.
%
% Parameters:
%   L
%     The n-by-n Laplacian matrix
%   dt
%     The simulated time step
%   agentVelocity
%     n-by-2 vector of velocities for n agents, in [x1 y1; x2 y2; ...]
%     format, before the update
%
% Returns:
%   agentVelocity
%     n-by-2 vector of velocities for n agents, in the above format,
%     after the update

agentVelocity = agentVelocity - dt*L*agentVelocity;
