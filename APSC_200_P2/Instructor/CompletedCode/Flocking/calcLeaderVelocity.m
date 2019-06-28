function leaderVelocity = calcLeaderVelocity(velocityFunction,duration,dt)
%% calcLederVelocity
% Calculates the velocity of the leader agent for all iterations of the
% simulation. Note that this function is called once at the beginning of
% the program, and the leaderVelocity returned should contain the leader's
% velocity at each discrete time step.
%
% Parameters:
%   velocityFunction
%     1-by-2 symbolic expression in terms of symbolic variable t
%     representing the parametric velocity functions in x and y of the
%     leader
%   duration
%     Total duration the simulation will run for
%   dt
%     Amount of time simulated in each iteration
%
% Returns:
%   leaderVelocity
%     (duration/dt + 1)-by-2 matrix of the velocity function evaluated from
%     t=0 to t=duration in discrete time steps of dt

syms t;
leaderVelocity = subs(velocityFunction,t,dt*(0:duration/dt)');
