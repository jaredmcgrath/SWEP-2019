function agentPositions = agentPositionFix(agentPositions,partitions,sides)
%% agentPositions
% Helper function to correct initial agent positions. Should be called upon
% initialization of a simulation
%
% Parameters:
%   agentPositions
%     n-by-2 vector of the x, y positions for n agents before moving
%   partitions
%     Number of subdivisions within each unit length of the arena
%   sides
%     Side length of arena
%
% Returns:
%   agentPositions
%     n-by-2 vector of the x, y positions for n agents after moving

% Ensure agents fall on a partition gridline
agentPositions = ceil(agentPositions*partitions)/partitions;
% Ensure no 2 agents occupy same position
[~, ia, ic] = unique(agentPositions, 'rows');
maxVal = 0;
if size(ia,1) ~= size(ic,1)
    for i = 1:size(ic,1)
        if ic(i) <= maxVal
            % Need to bump agent. If on boundary, then inwards
            if agentPositions(i,1) == 1/partitions
                agentPositions(i,1) = 2/partitions;
            elseif agentPositions(i,1) == sides
                agentPositions(i,1) = agentPositions(i,1) - 1/partitions;
            elseif agentPositions(i,2) == 1/partitions
                agentPositions(i,2) = 2/partitions;
            elseif agentPositions(i,2) == sides
                agentPositions(i,2) = agentPositions(i,2) - 1/partitions;
            % Otherwise, doesn't matter where
            else
                agentPositions(i,2) = agentPositions(i,2) + 1/partitions;
            end
        else
            maxVal = ic(i);
        end
    end
end