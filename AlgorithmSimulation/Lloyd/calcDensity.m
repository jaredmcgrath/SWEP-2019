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

syms t;
D = subs(D,t,iteration);
if isequal(size(D), [1 1])
    syms x y;
    % Get all x,y points for substitution
    [X,Y] = meshgrid(1:sides*partitions, 1:sides*partitions);
    X = X/partitions;
    Y = Y/partitions;
    density = double(subs(D,{x,y},{X,Y}));
else
    density = double(D);
end