function h = calcTrilatH(x,b_loc)

% Args
% x is the state of our system, x = [x,y,theta], theta is in [0,2pi] in rad
% v is the measurement noise added at each step
% b_loc is an array of beacon locations [x1,y1;x2,y2,...]

% Returns
% [d1;d2;...dm], distances between the bot and each beacon

h = zeros(size(b_loc,1),1);

for i = 1:size(b_loc,1)
    h(i) = norm(x(1:2) - b_loc(i,:));
end


end