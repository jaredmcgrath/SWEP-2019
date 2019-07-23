function deltaEnergy = energyFunction(velocity, deltaPosition, dt)
%% energyFunction
% Determines how much energy each agent uses when moving.
% This can incorporate kinetic energy, friction, etc. to update battery
% levels
%
% Parameters:
%   velocity
%     n-by-1 vector of the velocity that each agent travelled at in the
%     previous iteration
%   deltaPosition
%     n-by-2 vector of the change in position (deltaX, deltaY) of each
%     agent
%   dt
%     Simulated time step
%
% Returns:
%   deltaEnergy
%     n-by-1 vector of the change in energy for each agent (negative if
%     energy is being used)
