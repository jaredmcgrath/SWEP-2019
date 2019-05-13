function [A] = GetA(A_Overall, loc)
% GetA: The purpose of this  function is to obtain the specifed A matrix 
% that is to be used in the main GUI for plotting. 
%   The overall A matrix (A_Overall) is passed into the function along with
%   the parameter of loc. loc identifies which A matrix from the overall
%   set of A Matrices is to be returned.

% A_Overall is saved as a 3D stack of A matrices that you created in the
% A_Matrix_Creator GUI. The x,y components form the A matrix for the n 
% number of agents used. The z component indicates which A matrix in the 
% stack of matrices that you are working with.

% HINT: It should only take one line of code to achieve this

A = A_Overall(:,:,loc);
end

