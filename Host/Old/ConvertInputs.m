function [Wl, Wr] = ConvertInputs(u, r, Rad)
%this function converts control inputs from unicycle to differential drive

Wr = u(1)./r + Rad.*u(2)./r;
Wl = u(1)./r - Rad.*u(2)./r;

end 
