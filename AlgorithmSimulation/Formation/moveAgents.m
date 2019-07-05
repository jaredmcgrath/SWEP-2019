function agentData = moveAgents(agentData, L, time, dt)
%% moveAgents
% Move agents (and update any agent info, including enegry) whilst taking
% into account the Laplacian, time delays (tau), offsets, energy, the 
% current time, and time step.
%
% Parameters:
%   agentData
%     n-by-6 vector of agent data before update, where:
%       column 1 is x position
%       column 2 is y position
%       column 3 is tau
%       column 4 is x offset
%       column 5 is y offset
%       column 6 is energy
%   L
%     Laplacian matrix for this iteration
%   time
%     Current (simulated) time
%   dt
%     Simulated time step over which the agents will move
%
% Returns:
%   agentData
%     n-by-6 vector of agent data after update, in the above format

originalPositions = agentData(:,1:2);
% Find time-delayed agents by tau
timeDelayedAgents = find(agentData(:,3) >= time);
% Update Positions
agentData(:,1:2) = agentData(:,1:2) - (dt * (L * (agentData(:,1:2)...
    - agentData(:,4:5))));
% Revert time delayed agents to not move
agentData(timeDelayedAgents,1:2) = originalPositions(timeDelayedAgents,:);
