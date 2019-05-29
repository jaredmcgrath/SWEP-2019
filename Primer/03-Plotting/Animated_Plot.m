%% ANIMATED LINE PLOT
% We are using a script file instead of a .mlx file becasue in the .mlx
% file only the final plot would be displayed instead of the animation, and
% the whole purpose of this tutorial is how to create an animated line.

% Suppose that you want to create a plot that graudally updates as the
% program runs. To do this, you can use the animatedline function in Matlab
% below is some sample code on how to use the animated line function.

% More detailed documentation can be found on the MATLAB Documentation
% page: https://www.mathworks.com/help/matlab/ref/animatedline.html

%% CODE

f = animatedline;
axis([-5,5,-5,5])

grid on;

t = linspace(0,10,1000);
x1 = sqrt(t).*cos(t);
y1 = sqrt(t).*sin(t);

for i = 1:1000
    addpoints(f,x1(i),y1(i));
    drawnow 
end

