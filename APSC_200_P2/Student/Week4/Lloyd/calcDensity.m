function density = calcDensity(D,iteration,sides,partitions)
%% calcDensity
% Calculates the density matrix for the given iteration
%
% Parameters:
%   D
%     Symbolic function of x, y, t, or matrix of symbolic functions of t
%   iteration
%     The current iteration
%   (optional) sides
%     Side length of the arena
%   (optional) partitions
%     Number of subdivisions within each unit length of the arena
%
% Returns:
%   density
%     (sides*partitions)-by-(sides*partitions) matrix of doubles
%     representing discretized density for the given iteration
%% Your Code Below
