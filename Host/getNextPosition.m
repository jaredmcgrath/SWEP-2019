function [nextPosition] = getNextPosition(algorithm, botTags, currentPosition)
%Using the algorithm that the user has chosen, the next position of all of
%the robots is calculated
nextPosition = zeros(length(botTags),2);

if (algorithm == 1) 
    nextPosition = Flocking(); %%%%NOT DONE
elseif (algorithm == 2)
    nextPosition = Formation(botTags, currentPosition); 
elseif (algorithm == 3)
    nextPosition = Deployment(); %%%%NOT DONE
elseif (algorithm == 4)
    nextPosition = Krause(); %%%%IN PROGRESS
else
    nextPosition(:,1) = input('Input the next x-position for the robot.' );
    nextPosition(:,1) = input('Input the next y-position for the robot.' );
end
    

end

