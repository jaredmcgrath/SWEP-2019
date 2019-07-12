classdef FrameIdResponse < XBeeResponse
    % This class is extended by all Responses that include a frame id
    
    properties (Dependent, SetAccess = private)
        frameId(1,1) uint8
    end
    
    methods
        function frameId = get.frameId(obj)
            frameId = obj.frameData(1);
        end
    end
end
