function [nextPosition] = getNextPosition(algorithm, botTags, currentPosition, algorithmParameters)
% Using the algorithm that the user has chosen, the next position of all of
% the robots is calculated
nextPosition = zeros(length(botTags),2);

if algorithm == 1 || algorithm == 2
    nextPosition = Formation(botTags, currentPosition, algorithm, algorithmParameters);
elseif algorithm == 3
    nextPosition = Flocking();
elseif algorithm == 4
    nextPosition = Krause();
elseif algorithm == 5
    nextPosition = Deployment();
else
    nextPosition(:,1) = input('Input the next x-position for the robot.' );
    nextPosition(:,1) = input('Input the next y-position for the robot.' );
end
    

end

