function [algorithmParameters] = algorithmSettings(algorithm, botTag)
%% algorithmSettings
% This function takes in the required parameters for the algorithm selected

% Formation with fixed Matrix
if algorithm == 1 % Formation with fixed Matrix
    algorithmParamters = zeros(length(botTag), length(botTag));
    for i = 1:length(botTag)
        for j = 1:length(botTag)
            if (i == j)
                algorithmParamters(i,j) = input('Input the robots ''trust'' value for its own position. This is recommended to be at least 1.');
            else
                algorithmParamters(i,j) = input(['Input how much robot ' botTag(i) ' trusts ' botTag(j) '.']);
            end
        end
    end
    
% Formation with Communication Radii
elseif algorithm == 2
    algorithmParameters = input('Choose the size of communication bubbles.');

% Flocking
elseif algorithm == 3 
    algorithmParameters(1) = input('K: ');
    algorithmParameters(2) = input('sigma: ');
    algorithmParameters(3) = input('Beta: ');
    
% Opinion
elseif algorithm == 4 
    algorithmParameters = zeros(1, length(tagBot));
    for agent = 1:length(tagBot)
        prompt = ['Radius of Communication for Agent', tagBot(agent)];
        algorithmParameters(1,agent) = input(prompt);
    end
    
% Lloyd's    
else
    algorithmParameters = 'TBD';
end
end

