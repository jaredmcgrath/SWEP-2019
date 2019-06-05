function leaderVelocity = calcLeaderVelocity(velocityFunction,duration,...
    timeStep)
%% calcLederVelocity
% Calculates the velocity of the leader agent over the duration of
% the simulation
%
% Parameters:
%   velocityFunction
%     1-by-2 symbolic expression in terms of symbolic variable t
%     representing the parametric velocity functions in x and y of the
%     leader
%   duration
%     Number of iterations for which the simulation will run
%   timeStep
%     Simulated duration of each iteration
%
% Returns:
%   leaderVelocity
%     (duration+1)-by-2 matrix of the velocity function evaluated from t=0 
%     to t=duration*timeStep in discrete time steps
%% Your Code Below