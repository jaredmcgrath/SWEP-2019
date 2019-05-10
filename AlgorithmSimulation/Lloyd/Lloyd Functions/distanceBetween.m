function distance = distanceBetween( x1, y1, x2, y2,E_i)
% Finds distance between two points using pythagorean theorem.
% If using this function in 2D, enter z1 = z2 = 0 into the function. If you
% need a custom distance function (something that considers the energy of
% each agent may be useful to have), then algorithm_type = 2; so you must
% write your custom distance function in line 10.
% E_i: Energy of agent i
distance = sqrt((x2-x1)^2 + (y2-y1)^2);