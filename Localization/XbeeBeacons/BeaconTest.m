%% BEACON STRENGTH RESULTS
% June 27, 2019
% 
% This program generates a 3D plot of the Radio Signal Strength of received
% transmissions by a transmitter placed at specified points over a 2D grid.
% The X-Y plane is the plane where the transmittter is placed, the Z-axis
% denotes the strength of the signal received.

%% IMPORT EXCEL DATA
% Import test results from given excel spreadsheet
results = readmatrix('BeaconTest.xlsx','Range','A6:C22');

xCoordinate = results(:,1);
yCoordinate = results(:,2);
RSS = results(:,3);

%% PLOTTING RESULTS
% Plotting the results in 3D

scatter3(xCoordinate,yCoordinate,RSS);

%% ALTERNATE METHOD (only uses MATLAB)
