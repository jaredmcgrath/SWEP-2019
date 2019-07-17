classdef Tx16Request < XBeeRequest
    % Represents a Series 1 TX packet that corresponds to Api Id: 
    % TX_16_REQUEST
    % There should be a PayloadRequest superclass in this hierarchy.
    % However, at the time of writing, MATLAB doesn't support Abstrat
    % property validation methods being redefined in concrete subclasses.
    % Hence, Tx16 and Tx64 contain mostly the same code except for the size
    % constrait on address
    
    properties (Dependent, SetAccess = protected)
        frameData
    end
    
    properties (Constant)
        apiId = XBeeConst.TX_16_REQUEST
    end
    
    properties
        address(1,1) uint16
        option(1,1) uint8 = XBeeConst.ACK_OPTION
        payload(1,:) uint8 = []
    end
    
    methods
        function obj = Tx16Request(address, payload, frameId, option)
            % If no arguments given, use empty payload, broadcast address,
            % with default frame and ACK option
            switch nargin
                case 0
                    error("You must specify an address to construct a Tx16Request");
                case 1
                    obj.address = address;
                case 2
                    obj.address = address;
                    obj.payload = payload;
                case 3
                    obj.address = address;
                    obj.payload = payload;
                    obj.frameId = frameId;
                case 4
                    obj.address = address;
                    obj.payload = payload;
                    obj.frameId = frameId;
                    obj.option = option;
            end
        end
        
        function frameData = get.frameData(obj)
            frameData = [obj.address obj.option obj.payload];
        end
        
        function address = get.address(obj)
            address = flip(typecast(obj.address,'uint8'));
        end
    end
end