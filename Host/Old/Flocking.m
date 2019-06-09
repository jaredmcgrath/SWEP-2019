function [] = Flocking(bots)
%Flocking Algorithm, adaptation of flocking_play from the flocking gui
%%%%%may still need adjustment to work with the robotic system

%Get the intitial positions of all of the robots
initialPosition = PositionCalc(bots);

%Get the initial velocities from the user and the K, beta, and sigma values
velocity = zeroes(length(bots));
for i = 1:length(bots)
    string = ['Input the velocity of robot ',bots(i)];
    velocity(i) = input(string);
end
K = input('Choose a K value');
beta = ('Choose a beta value');
sigma = ('Choose a sigma value');

%Define the adjacency matrix by the distances between the nodes
Adj = zeros(length(bots));

%Choose a timestep
deltaT = input('Choose a time step, (ex = 0.1)');

%Choose the arena dimension (assuming a square, dimension = length)
arenaDim = input('What is the square arena dimension?');

%Input your trigger sequence here to determine on which time iterations
%your agents will update their velocities
trigger = ones(1,100);

%Choose a leader
leader = input('Choose a tag of a robot to be the leader.', 's');
for i = 1:length(bots)
    if (bots == leader)
        leaderIndex = i;
    end
end

%Decide on a dersired trajectory
trajX = input('Choose a desired x-trajectory');
trajY = input('Choose a desired y-trajectory');

stop = false;
%use the stop variable to stop the loop when desired
while(~stop)
    %Calculate the pairwise distance of the bots and use it to fill in the
    %adjacency matrix
    for i = 1:length(bots)
        for j = 1:length(bots)
            distance = pdist([initialPosition(i,1), initialPosisiton(i,2); initialPosition(j,1), initialPosition(j,2)]);
            Adj(i,j) = K / ((sigma^2 + distance^2)^beta);
        end
    end
    
    %Check to see if the leader has the user's desired trajectory
    if (isempty(trajX) == 0 && isempty(trajY) == 0)
        %Write a function to define leader trajectory
        func_x = trajX;
        func_y = trajY;
        fileID = fopen('trajectory.m','w');
        fprintf(fileID,'function [x,y] = trajectory\n');
        fprintf(fileID,'clear all \n');
        fprintf(fileID,'x(1)=0; \n');
        fprintf(fileID,'y(1)=0; \n');
        fprintf(fileID,'for t=2:%d \n',((t+1)/2)+2);
        fprintf(fileID,'x(t) = %s;\n',func_x);
        fprintf(fileID,'y(t) = %s;\n',func_y);
        fprintf(fileID,'end\n');
        fprintf(fileID,'end\n');
        fclose(fileID);
        [x_pos,y_pos]=trajectory;

        %Store the x and y positions of the leader in a single vector (pos)
        for i=1:size(x_pos,2)-1
            pos(2*i-1)=x_pos(i);
            pos(2*i)=y_pos(i);
        end
        %Calculate the velocity of leader
        for i=1:((t+1)/2)+1
            x_vel(i)=x_pos(i+1)-x_pos(i);
            y_vel(i)=y_pos(i+1)-y_pos(i);
        end
        %Store the x and y velocity in a single vector (vel)
        for i=1:size(x_vel,2)
            vel(2*i-1)=x_vel(i);
            vel(2*i)=y_vel(i);
        end
    end
    
    %%%%May need to be adjusted%%%%%
    %Update positions using the algorithm
    initialPosition(:,t+2) = initialPosition(:,t) + deltaT*velocity(:,t);
    initialPosition(:,t+3) = initialPosition(:,t+1) + deltaT*velocity(:,t+1);
    %Reset the leader's (ie first node) position to what was
    %calculated above
    if (isempty(trajX) == 0 && isempty(trajY) == 0)
        initialPosition(1,:) = pos;
    end
    %Compute Laplacian Matrix L
    w = Adj*ones(length(bots),1);
    D = diag(w);
    L = D - Adj;
    if (trigger((t+1)/2) == 1)
        velocity(:,t+2) = velocity(:,t) - deltaT*L*velocity(:,t);
        velocity(:,t+3) = velocity(:,t+1) - deltaT*L*velocity(:,t+1);
    else
        velocity(:,t+2) = velocity(:,t);
        velocity(:,t+3) = velocity(:,t+1);
    end
    %Reset the leader's (ie first node) position to what was
    %calculated above
    if (isempty(trajX)==0 && isempty(trajY)==0)
        velocity(1,:)=vel;
    end
    %Increment the time by 2 since the Hx=[x_position,y_position] and
    %Hv=[x_vel,y_vel]
    t = t+2;
    end
    
end

