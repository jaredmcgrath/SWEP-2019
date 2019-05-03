function [positionEstimation] = EncoderToPosition(oldEncoderValues, encoderValues, oldPosition)
%Determines the position of a robot from its encoder values using the
%mechanics of the system

%Determine the radians each wheel travelled determined from the encoder ticks 
leftRadians = (encoderValues(:, 1) - oldEncoderValues(:, 1))*2*pi/192; %in radians 
rightRadians = (encoderValues(:, 2) - oldEncoderValues(:, 2))*2*pi/192;

%determine the angle of the robot
positionEstimation(:,3) = oldPosition(:,3) + 1/2*0.063/2*(1/(0.126/2))*(rightRadians - leftRadians);

%make sure that the angle is in the -pi to pi range
while(abs(positionEstimation(:, 3)) >= pi)
    if (positionEstimation(:, 3) > 0)
        positionEstimation(:, 3) = positionEstimation(:, 3) - 2*pi;
    else
        positionEstimation(:, 3) = positionEstimation(:, 3) + 2*pi;
    end
end

%Use localisation
for i = 1:length(bots)
    positionEstimation(i,1) = oldPosition(i,1) + cos(oldPosition(i,3)).*0.065.*0.5.*0.5.*(leftRadians(i) + rightRadians(i));
    positionEstimation(i,2) = oldPosition(i,2) + sin(oldPosition(i,3)).*0.065.*0.5.*0.5.*(leftRadians(i) + rightRadians(i));
end

end

