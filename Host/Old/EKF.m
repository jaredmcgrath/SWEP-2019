function [errorCovMat, positionEstimation] = EKF(positionPrediction, ...
    oldPosition, beaconDistances, beaconLocations, errorCovMat, ...
    validLocalizationTx)

% Args:

% Description:
% Uses an EKF in order to estimate current position. This
% function has been changed extensively since its creation as part of the
% simulation, and now consists just of just the corrective step for the 
% next iteration. The predictive step occurs on the bots in order to cut
% down on communication traffic/time

% Notes:
% IMPORTANT: Note the use of middleman variables in this script 
% See bottom of this file for a system definition, and brief
% explanation of variable names

% TO DO:
% make sure time_step is the same as movementDuration in the 'duino code


%% Middleman variables created when ported from simulation

% Would do a search and replace, but beaconLocations is very long, and
% b_loc is somewhat unintuitive
b_loc = beaconLocations; 
P = errorCovMat;
x_hat_old = oldPosition; 
x_pre_hat = positionPrediction;


%% Mathematical Setup
n = 3;  % State dimension
m = size(b_loc,1);  % Observability dimension

% Vehicle parameters
r = 0.065/2;    % wheel radius [m]
wheelbase = 0.126/2;    % chassis wheelbase [m]

% Approximate time between steps, used in calculating the variance of
% velocity
time_step = 1;


%% Sensor variances and uncertainties
% Encoder variance
% Note: we assume the encoder is accurate to within each of its 192 ticks.
% We then assume that there is a normal
% distribution associated with this accuracy, with 3*sigma (standard
% deviation) 0.065*pi/192 = 0.00106m. This induces the following variance (in m). Note
% assume no wheel slip
encoder_var = (r*pi/192/3)^2;
theta_r_var = (r/wheelbase)^2*encoder_var;

% Control variables variances (u = [v;omega])
% v
% We have that v = 1/2*r(omega_r + omega_l) =
% 1/2*r/time_step*(theta_l+theta_r). Thus,
v_var = (r/(2*time_step))^2*2*theta_r_var;
% omega (gyro) variance
% Given that the gyro has a total RMS noise value of 0.05 deg/s rms, and
% that RMS^2 = Var, we have that
omega_var = (0.05*pi/180)^2;

% Sensor variances
trilat_accuracy = 0.01; % 1cm accuracy in distance calculation

% Covariance of noise
% [lxl] Process(control input) noise covariance(u = [v;omega])
Q = diag([v_var; omega_var]);

% [mxm] Measurement noise covariance
R = trilat_accuracy*eye(m,m);


%% Functions used in EKF corrective step
% Note that we can define these as constants (as opposed to function
% handles) since we are only estimating the state of the current time step
% based off of the previous time step (instead of in the simulation where
% it estimates state in a for loop)

% Measurement (ie. convert state to what we are measuring. Note that the
% noise inputted is zero).
% z(k) = h(x(k),v(k)))
h = calcTrilatH(x_pre_hat,b_loc);

% Jacobians. Note that the control input u is noisy (ie. u + w)
% del f/del x
A = [1, 0, -sin(x_hat_old(3))*norm(x_pre_hat(1,2) - x_hat_old(1,2));...
    0, 1, cos(x_hat_old(3))*norm(x_pre_hat(1,2) - x_hat_old(1,2));...
    0, 0, 1];
% del f/del w
W = [cos(x_hat_old(3)), 0; sin(x_hat_old(3)), 0; 0, 1];
% del h/del x
H = calcTrilatDelH(x_pre_hat,b_loc);
% del h/del v
V = eye(m,m);  % Since measurement noise added linearly


%% EKF (corrective step, predictive step done on the bots)

% Project previous uncertainty
P_pre = A*P*A' + W*Q*W';

% Noisy measurement (what our sensors actually read). Take tranpose so that
% we are able to input a row vector for distances, but have this code work
z_hat = beaconDistances';

% Estimated State (where we think we are)
% Update our model only if the beacon distances are new
if validLocalizationTx
    K = P_pre*H'*inv(H*P_pre*H' + V*R*V');
else
    K = zeros(n,m);
end

% Determine predicted measurements based off of state
z_pre_hat = h;

% Correction step. Take transposes to make this script (which mainly uses
% column vectors) to work with rest of code
x_hat = x_pre_hat + (K*(z_hat - z_pre_hat))';

% Update/correct the predicted uncertainty
P = (eye(n) - K*H)*P_pre;


% Yet another middleman variable to make connections between the math and
% the actual system more intuitive
positionEstimation = x_hat;
errorCovMat = P;
end


%% System Defition
% We attempt to recover the state x(k) in R^n of a discrete time system
% governed by the (non-linear) eqn
%
%   x(k) = f(x(k-1),u(k),w(k-1))
% 
% with a measurement z in R^m that is 
% 
%   z(k) = h(x(k),v(k))
%
% The random variables w (process noise) and v (measurement noise) have
% unknown distributions (would be w~N(0,Q), v~N(0,R), but they have 
% undergone non-linear transformations.
%
% See the following link for a more complete explanation:
% http://www.cs.unc.edu/~tracker/media/pdf/SIGGRAPH2001_CoursePack_08.pdf