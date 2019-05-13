function [L] = CalculateL(A,D)
% CalculateL: The purpose of this function is to calcualte the L matrix
% required by the GUI given the A and D matrices calcualted previously
%   This function uses the A matrix obtained from GetA and the D matrix
%   calcualted in CalcualteD. Using these two parameters, the resulting L
%   matrix can be written

% HINT: This should only take one line of code

L = D - A;
end

