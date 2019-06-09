function H = calcTrilatDelH(x,b_loc)

% Args
% x is the state of our system, x = [x,y,theta], theta is in [0,2pi] in rad
% v is the measurement noise added at each step
% b_loc is an array of beacon locations [x1,y1;x2,y2,...]

H = zeros(size(b_loc,1),3);

for i = 1:size(b_loc,1)
    H(i,:) = [(x(1) - b_loc(i,1))/norm(b_loc(i,:) - x(1:2)),...
        (x(2) - b_loc(i,2))/norm(b_loc(i,:) - x(1:2)),...
        0];
end

end