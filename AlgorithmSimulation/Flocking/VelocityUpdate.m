function agentVelocityUpdated = VelocityUpdate(L,timeStep,agentVelocity)
%% Velocity Update
%   This function updates the velocity of each agent using the Laplacian
%   Matrix given
%   
%   Parameters:
%       L -- Laplacian Matrix
%       agentVelocity -- the x,y velocity of each agent
%
%   Returns:
%       agentVelocityUpdated

%% Function Code

agentVelocityUpdated = zeros(size(agentVelocity,1),2);

agentVelocityUpdated(:,1) = agentVelocity(:,1) - timeStep*L*agentVelocity(:,1);
agentVelocityUpdated(:,2) = agentVelocity(:,2) - timeStep*L*agentVelocity(:,2);

end

