function A = getA(matrix, iteration)
%% getA
% Selects a 2D matrix from a 3D matrix using the current iteration. Info
% other than the current iteration could be used to determine A matrix
% instead.
%
% Parameters:
%   matrix
%     The 3D matrix loaded from file by the simulation app
%   iteration
%     Current iteration of the simulation
%
% Returns:
%   A
%     2D matrix selected from 'matrix'

A = matrix(:,:,1);
