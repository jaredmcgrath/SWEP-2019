function [newPosition] = localization(rssi,xBot,yBot)
% LOCALIZATION This function takes in the rssi readings and the position
% of the robots based on dead reckoning and returns the new positions of 
% the robots
%   This function takes the received RSSI values and converts the values
%   into distances. These distances are then used in the min-max
%   localization method to determine the position of the robot(s). This
%   position is then fused with that from the deadreckoning to determine
%   the most probable location of the robot

% Obtains distances from RSSI readings. rssi is a m x n matrix where m
% denotes the number of robots and n denotes the number of beacons
dist = 0.0854.*rssi.^2+1.8452.*rssi-1.0415;

% Set up grid parameters (PROBABLY CAN BE USER ENTERED OR FROM CONFIG)
grid_length_x = 300;
grid_length_y = 300;
x_grid = 1:grid_length_x;
y_grid = 1:grid_length_y;
[X,Y] = meshgrid(x_grid,y_grid);

% Beacon Locations (SHOULD BE FROM CONFIG FILE)
Beacon_1 = [0,0];
Beacon_2 = [150,300];
Beacon_3 = [300,0];

% Creating Squares around each beacon using correpsonding distance
% TO DO: perhaps put this into a for loop that generates the squares based on
% the number of beacons in the system
square_1 = [Beacon_1(1) - dist(1), Beacon_1(2) + dist(1);
           Beacon_1(1) + dist(1), Beacon_1(2) + dist(1);
           Beacon_1(1) + dist(1), Beacon_1(2) - dist(1);
           Beacon_1(1) - dist(1), Beacon_1(2) - dist(1)];

square_2 = [Beacon_2(1) - dist(2), Beacon_2(2) + dist(2);
           Beacon_2(1) + dist(2), Beacon_2(2) + dist(2);
           Beacon_2(1) + dist(2), Beacon_2(2) - dist(2);
           Beacon_2(1) - dist(2), Beacon_2(2) - dist(2)];
       
square_3 = [Beacon_3(1) - dist(3), Beacon_3(2) + dist(3);
           Beacon_3(1) + dist(3), Beacon_3(2) + dist(3);
           Beacon_3(1) + dist(3), Beacon_3(2) - dist(3);
           Beacon_3(1) - dist(3), Beacon_3(2) - dist(3)];

% Checking which grid points are in each square 
% TO DO: perhaps put this into a loop based on the number of beacons being
% used
in_square1 = inpolygon(X, Y, square_1(:,1), square_1(:,2));
in_square2 = inpolygon(X, Y, square_2(:,1), square_2(:,2));
in_square3 = inpolygon(X, Y, square_3(:,1), square_3(:,2));

% Finding the overlap 
% TO DO: find a way to have this condiitonal refelct the number of beacons
% being used. Also introdue logic to disregard faluty beacon readings from
% the calcualtion. Also introduce this in a loop of matrix operations. 
overlap_x = any(in_square1 & in_square2 & in_square3);
overlap_y = reshape(any(in_square1 & in_square2 & in_square3, 2),1,[]);

% Creating rectangle where all rectangles overlap
target = [find(overlap_x,1),        find(overlap_y,1);
          find(overlap_x,1,'last'), find(overlap_y,1);
          find(overlap_x,1,'last'), find(overlap_y,1,'last');
          find(overlap_x,1)         find(overlap_y,1,'last')];

% Calculating the centroid of the overlap rectangle
[x_centroid , y_centroid] = centroid(polyshape(target(:,1),target(:,2)));
 
end

