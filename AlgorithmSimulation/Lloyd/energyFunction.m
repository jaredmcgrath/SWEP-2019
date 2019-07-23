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

%% Constants
% Physical mass of agents, kg
m = 0.5;
% Unit(s) of space per length-sides, m
unitSpace = 1;
%% Example
% This example defines energy change to be
% E_(i+1) = E_i - (1/2)*m*v^2

% Note that this velocity, v, is supposed to be in m/s
v = vecnorm(deltaPosition,2,2)*unitSpace/dt;

% Calculate change in energy (always negative, this could change)
deltaEnergy = (-1/2)*m*(v.^2);
