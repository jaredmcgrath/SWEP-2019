classdef TxStatusResponse < FrameIdResponse
    % Represents a Series 1 Tx Status packet
    
    properties (Dependent, SetAccess = private)
        status(1,1) uint8
        isSuccess(1,1) logical
    end
    
    methods
        function status = get.status(obj)
            status = obj.frameData(2);
        end
        
        function isSuccess = get.isSuccess(obj)
            isSuccess = obj.status == XBeeConst.SUCCESS;
        end
    end
end