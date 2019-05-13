function [D] = CalculateD(A)
%CalcualteD: This function calcualtes the D matrix corresponding to a
%given A matrix.
%   From your notes, you know how to calcualte the D matrix given an a
%   matrix. Write this formula out in code returninf the calcualted D
%   matrix to the GUI

% HINT: You will probably need a nested for loop

num_agents = size(A,1);
D = zeros(num_agents);

for i = 1:num_agents
    for j = 1:num_agents
        D(i,i) = D(i,i) + A(i,j);
    end
end

end

