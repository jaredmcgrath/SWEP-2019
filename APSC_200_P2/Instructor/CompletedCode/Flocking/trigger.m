function trigger = trigger(time)
%% trigger
% Trigger sequence for simualtion. If agents should communicate/update 
% their velocities at the current time, return 1. Otherwise, return 0.
%
% Parameters:
%   time
%     Current time
%
% Return:
%   trigger
%     1 is trigger activated, 0 otherwise

trigger = 1;
