function [leftWheel, rightWheel, error] = Control(q, desiredPosition, i, e, leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept)
%Uses the current position and the desired position to determine what the
%wheels of a robot should do to get where it needs to be
%% constants

Rad = 0.126/2; %Distance from center of chassis to wheel
r = 0.063/2; %radius of wheel

%% Parametric Path and State Arrays
q = q';
disp(q);
qd = zeros(3,1);
qd(1:2) = desiredPosition(1:2)' %assuming our desired position is only an x,y coordinate
Vn = 0.2; %desired velocity in m/s (constant, so we can decide what this needs to be)
Vd = Vn;
%% Linear Quadratic Regulator Conditions

Q = [8, 0, 0;0, 6, 0;0, 0, 15]; %Weighting matrix for importance of the three errors forward, lateral, theta
R = [3, 0; 0, 1]; %Cost matrix for V, W. High cost ensures we don't max out at 255 for every control input. 

%These matrices will need to be tuned once we're working with the real
%robots.

%% Control
qd(3) = atan2(qd(2)-q(2), qd(1)-q(1));
e(:,i) = q(:) - qd(:);
e(3, :) = unwrap(e(3,:));
[Vd, qd(:)] = GetInput(Vd, qd, Vn, e(:,i));%This considers whether it is more efficient to travel backwards, and thus alter our desired angular velocity and velocity.
e(:, i) = q(:) - qd(:);
e(3, :) = unwrap(e(3,:));

error = e(:,i);

u = GetControl(qd, Q, R, Vd, e(:,i)); %Get control inputs

%% Convert Control inputs from unicycle to inputs understandable by arduino

[leftWheel, rightWheel] = ConvertInputs(u, r, Rad);%Convert from our unicycle model to inputs that are compatible with a differential drive robot
[leftWheel, rightWheel] = MappingInputs(leftWheel, rightWheel, leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept); %Map inputs from real numbers to +/- integer values between 0 and 255

%These can be commented in to force the wheels to go at a certain speed for
%all robots, this is mainly used for testing
%leftWheel = 0;
%rightWheel = 0;

end

