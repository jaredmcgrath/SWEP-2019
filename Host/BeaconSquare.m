classdef BeaconSquare
    % BeaconSquare
    % Used in the localization process. Constructed given a center location
    % and the distance (half the side length), the vertices are calculated.
    
    properties
        position(1,2) {mustBeNumeric}
        distance(1,1) {mustBeNumeric}
    end
    
    properties (Dependent, SetAccess = private)
        xVertices
        yVertices
    end
    
    methods
        function obj = BeaconSquare(pos,dist)
            obj.position = pos;
            obj.distance = dist;
        end
        
        function xVertices = get.xVertices(obj)
            xVertices = [obj.position(1) + obj.distance;...
                obj.position(1) + obj.distance;...
                obj.position(1) - obj.distance;...
                obj.position(1) - obj.distance];
        end
        
        function yVertices = get.yVertices(obj)
            yVertices = [obj.position(2) + obj.distance;...
                obj.position(2) - obj.distance;...
                obj.position(2) - obj.distance;...
                obj.position(2) + obj.distance];
        end
    end
end

