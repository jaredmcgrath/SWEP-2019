function controlInput = getControlInputs(config, position, heading,...
    desiredPosition, slope, intercept)
%% getControlInputs
% Determines the proper control inputs to move bots to their desired
% positions
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   position
%     n-by-2 vector of current positions for n agents
%   heading
%     n-by-1 vector of bot orientation(s), counter-clockwise from the
%     positive x-axis
%   desiredPosition
%     n-by-2 vector of desired positions for n agents
%   slope
%     n-by-2 matrix of slopes in [left right; left right; ... ] format,
%     where n is length of tagString
%   intercept
%     n-by-2 matrix of intercepts in [left right; left right; ... ] format,
%     where n is length of tagString
%
% Returns:
%   controlInput
%     n-by-2 vector of control inputs (-255<=input<=255) in 
%     [L1 R1; L2 R2; ... ] format

% TODO: Make the old code below work
% Old inputs were:
% q, desiredPosition, i, e, leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept
% Corresponding to:
% currentPosition(i,:), desiredPosition(i,:), index, error, ...
% Found in AdjustPosition.m
%% Constants
% TODO: Move constants to config file

% Distance from center of chassis to edge of wheel
rChassis = 0.126/2;
% Radius of wheel
rWheel = 0.063/2;

%% Parametric Path and State Arrays
% TODO: Adapt these variables to be compatible with multiple bots
% simultaneously
q = q';
qd = zeros(1,3);
qd(1:2) = desiredPosition(1:2);
% Desired velocity in m/s (constant, so we can decide what this needs to be)
Vn = 0.2;
Vd = Vn;

%% Linear Quadratic Regulator Conditions
% Weighting matrix for importance of the three errors forward, lateral, theta
Q = [8 0 0; 0 6 0; 0 0 15];
% Cost matrix for V, W. High cost ensures we don't max out at 255 for every control input. 
R = [3 0; 0 1];

%% Control
qd(3) = atan2(qd(2)-q(2), qd(1)-q(1));
e(:,i) = q(:) - qd(:);
e(3, :) = unwrap(e(3,:));

% Check if it would be more efficient to travel backwards
if abs(e(3)) > pi/2
    if qd(3)>0
        qd(3) = qd(3) - pi;
        Vd = -Vn;
    elseif qd(3) < 0
        qd(3) = qd(3) + pi;
        Vd = -Vn;
    end 
else 
    Vd = Vn;
end

e(:, i) = q(:) - qd(:);
e(3, :) = unwrap(e(3,:));

error = e(:,i);

%% Linearization
% Apply the linear model
% Evaluate matrix at desired inputs and location
A = [0, 0, -Vd*sin(qd(3));0, 0, Vd*cos(qd(3));0, 0, 0];
B = [cos(qd(3)), 0;sin(qd(3)), 0;0, 1];
% Compute gain matrix using LQR
K = lqr(A, B, Q, R);

% Get system inputs from gain matrix and error vector
u = -K*[0; 0; e(3)] + [Vd; 0];

%% Differential Drive
% Convert unicycle model to differential drive
Wr = u(1)./rWheel + rChassis.*u(2)./rWheel;
Wl = u(1)./rWheel - rChassis.*u(2)./rWheel;

% Apply the linear calibration coefficients to yield actual inputs
Wr = rightInputSlope*Wr + sign(Wr)*rightInputIntercept;
Wl = leftInputSlope*Wl + sign(Wl)*leftInputIntercept;

% Ensure wheel inputs are integers in the proper range
if abs(Wr) > 255
    Wr = 255*sign(Wr);
elseif abs(Wr) <= 100
    Wr = 0;
end
Wr = round(Wr);

if abs(Wl) > 255
    Wl = 255*sign(Wl);
    elseif abs(Wl) <= 100
    Wl = 0;
end
Wl = round(Wl);
