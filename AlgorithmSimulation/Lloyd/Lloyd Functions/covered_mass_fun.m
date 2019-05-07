function covered_mass = covered_mass_fun(Agent_Positions,Density,...
    r_o,Partition_Number,Number_of_Agents,algorithm_type)
% This function assumes that if an agent's radius covers some area, then
% the Density associated with each point in the area is observed. This
% might not be realistic depending on your application, so you can change
% your coverage function after line 23.
    covered_mass = 0;
for i = 1:size(Density,1)
    for j = 1:size(Density,1)
        check = 0;
        for k = 1:Number_of_Agents
            x = i/Partition_Number;
            y = j/Partition_Number;
            if (x - Agent_Positions(k,1))^2 + (y - Agent_Positions(k,2))^2 <= r_o^2 && check == 0
                check = 1;
                covered_mass = covered_mass + Density(i,j);
            end
        end
    end
end
end
