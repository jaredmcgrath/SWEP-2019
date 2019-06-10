function [Vd, qd] = GetInput(Vd, qd, Vn, e)

%This local function looks at whether it is more efficient for our robot to
%follow the desired curve forwards or backwards

%Our desired angle is the angle pointing from our current point to our
%desired point

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


%defining a desired angular velocity has multiple approaches when 
%we're moving to a constant point. We can rely
%solely on error (desired omega is zero). This will work, but may
%converge slower than desired. 

end 
