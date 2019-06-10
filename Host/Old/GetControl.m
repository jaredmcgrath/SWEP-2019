function u = GetControl(qd, Q, R, Vd, e)
%This function gets the control inputs

%A and B come from the linearized model. 

A = [0, 0, -Vd*sin(qd(3));0, 0, Vd*cos(qd(3));0, 0, 0]; %evaluate matrix at desired inputs and location
B = [cos(qd(3)), 0;sin(qd(3)), 0;0, 1];
K = lqr(A, B, Q, R); %This computes our gain matrix using LQR

u = -K*[0; 0; e(3)] + [Vd; 0]; %get the inputs for our system 
                %from the gain matrix, multiplied by the error vector

end 

