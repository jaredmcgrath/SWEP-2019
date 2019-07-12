classdef RxResponse < XBeeResponse
    % Respresents a Series 1 RX packet. Implicitly abstract; cannot be
    % instantiated directly
    
    properties (Dependent, SetAccess = private)
        address
        rssi
        option
        data
    end
    
    properties (Abstract, Constant)
        rssiOffset
        addressWidth
    end
    
    methods
        function rssi = get.rssi(obj)
            rssi = obj.frameData(obj.rssiOffset);
        end
        
        function option = get.option(obj)
            option = obj.frameData(obj.rssiOffset + 1);
        end
        
        function data = get.data(obj)
            data = obj.frameData(obj.rssiOffset+2:end);
        end
        
        function address = get.address(obj)
            address = obj.frameData(1:obj.addressWidth);
        end
    end
end