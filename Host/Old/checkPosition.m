function [inRange] = checkPosition(currentPosition,desiredPosition)
%Checks to see if the current range is in an epsilon ball of the desired
%position

%the epsilon value can be changed to adjust how close the robot has to be
%to the point before the robot can start approaching the next point
epsilon = 0.20; %in meters
inRange = false;
if(pdist([currentPosition(1,1), currentPosition(1,2); desiredPosition(1,1), desiredPosition(1,2)], 'euclidean') < epsilon)
    inRange = true;
end

end

