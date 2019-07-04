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

% TODO: Test new code
%% Constants
% Distance from center of chassis to edge of wheel
rChassis = config.rChassis;
% Radius of wheel
rWheel = config.rWheel;

%% Parametric Path and State Arrays
% Concatonate position and heading so q = [x1 y1 theta1; x2 y2 theta2; ...]
q = cat(2,position,heading);
% qd is desired position ()
qd = zeros(size(q));
qd(:,1:2) = desiredPosition;
% Desired velocity in m/s (constant, so we can decide what this needs to be)
% TODO: Move to config file?
Vn = 0.3*ones(size(q,1),1);
Vd = Vn;

%% Linear Quadratic Regulator Conditions
% Weighting matrix for importance of the three errors forward, lateral, theta
Q = [8 0 0; 0 6 0; 0 0 15];
% Cost matrix for V, W. High cost ensures we don't max out at 255 for every control input. 
R = [3 0; 0 10];

%% Control
qd(:,3) = atan2(qd(:,2)-q(:,2), qd(:,1)-q(:,1));
% Might need to unrap the theta error
e = q - qd;

% Find bots where it is more efficient to travel backwards
gtIndexes = find(e(:,3)>pi/2);
e(gtIndexes,3) = e(gtIndexes,3) - pi;
Vd(gtIndexes) = -Vd(gtIndexes);
ltIndexes = find(e(:,3)<-pi/2);
e(ltIndexes,3) = e(ltIndexes,3) + pi;
Vd(ltIndexes) = -Vd(ltIndexes);

% Not sure if error needs to be returned/kept track of
% error = e(:,i);

%% Linearization
% Preallocate uniqycle inputs
u = zeros(size(q,1),2);
% Apply the linear model to each bot in a loop
for i = 1:size(q,1)
    % Evaluate matrix at desired inputs and location
    A = [0 0 -Vd(i)*sin(qd(i,3)); 0 0 Vd(i)*cos(qd(i,3)); 0 0 0];
    B = [cos(qd(i,3)) 0; sin(qd(i,3)) 0; 0 1];
    % Compute gain matrix using LQR
    K = lqr(A, B, Q, R);
    % Get system inputs from gain matrix and error vector
    u(i,:) = -K*[0; 0; e(i,3)] + [Vd(i); 0];
end

%% Differential Drive
% Convert unicycle model to differential drive
controlInput = [(u(:,1) - rChassis.*u(:,2)), (u(:,1) + rChassis.*u(:,2))]...
    /rWheel;

% Old, for reference
% Wr = u(1)./rWheel + rChassis.*u(2)./rWheel;
% Wl = u(1)./rWheel - rChassis.*u(2)./rWheel;

% Apply the linear calibration coefficients to yield actual inputs
controlInput = (controlInput.*slope) + (sign(controlInput).*slope);

% Old, for reference
% Wr = rightInputSlope*Wr + sign(Wr)*rightInputIntercept;
% Wl = leftInputSlope*Wl + sign(Wl)*leftInputIntercept;

% Ensure wheel inputs are integers in the proper range
controlInput(controlInput>255) = 255;
controlInput(controlInput<-255) = -255;
% boostIdx = find(abs(controlInput) > 40 & abs(controlInput) < intercept);
% controlInput(boostIdx) = sign(controlInput(boostIdx)).*(intercept(boostIdx)+30);
controlInput = round(controlInput);

% Old, for reference
% if abs(Wr) > 255
%     Wr = 255*sign(Wr);
% elseif abs(Wr) <= 100
%     Wr = 0;
% end
% Wr = round(Wr);
% 
% if abs(Wl) > 255
%     Wl = 255*sign(Wl);
%     elseif abs(Wl) <= 100
%     Wl = 0;
% end
% Wl = round(Wl);
