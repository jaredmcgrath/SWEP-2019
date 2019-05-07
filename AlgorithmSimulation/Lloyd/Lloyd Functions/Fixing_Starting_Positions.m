function Agent_Positions = Fixing_Starting_Positions(Agent_Positions, Partition_Number,sides)
% This function ensures that the agents begin on partition lines. This
% should only be called at the beginning of the simulation.

n = size(Agent_Positions,1); % Get number of robots

for i = 1:n
    Agent_Positions(i,1) = ceil(Agent_Positions(i,1)*Partition_Number)/Partition_Number;
    Agent_Positions(i,2) = ceil(Agent_Positions(i,2)*Partition_Number)/Partition_Number;
end

Agent_Positions = Check_Repetition(Agent_Positions,Partition_Number,sides);

end