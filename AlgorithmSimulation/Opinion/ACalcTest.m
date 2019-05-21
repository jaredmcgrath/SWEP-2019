function [A] = ACalcTest(nodeData)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
tic;

nodes = size(nodeData,1);

A = zeros(size(nodeData,1));

nodeX = nodeData(:,1);
nodeY = nodeData(:,2);
radii = nodeData(:,3);
leftNoise = nodeData(:,4);
rightNoise = nodeData(:,5);


for i=1:nodes
    for j=1:nodes
        if norm([nodeX(i),nodeY(i)]-[nodeX(j),nodeY(j)])< radii(i)- leftNoise(i) || norm([nodeX(i),nodeY(i)]-[nodeX(j),nodeY(j)]) < radii(i) - rightNoise(i)
            A(i,j)=1;
        end
    end
end
toc;
end

