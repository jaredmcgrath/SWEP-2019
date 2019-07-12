classdef XBeeResponse
    % XBeeResponse is the root class for all XBee response packets
    %
    % A major design choice is the difference between construction of
    % properties for XBeeResponse- and XBeeRequest-like objects:
    % XBeeResponse objects are instantiated first, and then set their 
    % frameData explicitly, and a typecast to a subclass will enable 
    % interpretation of frame data based on the XBee protocol.
    % In contrast, XBeeRequest must be instantiated as a concrete subclass
    % and the frameData is a dependent property constructed by assigning
    % the appropriate properties of the subclass.
    
    properties
        msbLength(1,1) uint8 = 0
        lsbLength(1,1) uint8 = 0
        apiId(1,1) uint8 = XBeeConst.DEFAULT_FRAME_ID
        checksum(1,1) uint8 = 0
        frameData(1,:) uint8 = []
        isValid(1,1) {mustBeNumericOrLogical} = false
    end
    
    properties (Dependent, SetAccess = private)
        packetLength
    end
    
    methods
        % This is the length included directly in the xbee packet
        function packetLength = get.packetLength(obj)
            % Gets length from MSB/LSB
            packetLength = typecast([obj.lsbLength obj.msbLength],'uint16');
        end
        
        % Cast to Rx16Response
        function rx16Response = Rx16Response(obj)
            if obj.apiId == XBeeConst.RX_16_RESPONSE
                rx16Response = Rx16Response();
                rx16Response = copy(obj, rx16Response);
            else
                warning("Cast to Rx16Response failed");
            end
        end
        
        % Cast to Rx64Response
        function rx64Response = Rx64Response(obj)
            if obj.apiId == XBeeConst.RX_16_RESPONSE
                rx64Response = Rx64Response();
                rx64Response = copy(obj, rx64Response);
            else
                warning("Cast to Rx64Response failed");
            end
        end
        
        % Cast to TxStatusResponse
        function txStatusResponse = TxStatusResponse(obj)
            if obj.apiId == XBeeConst.TX_STATUS_RESPONSE
                txStatusResponse = TxStatusResponse();
                txStatusResponse = copy(obj, txStatusResponse);
            else
                warning("Cast to TxStatusResponse failed");
            end
        end
    end
end

% Private helper method to perform a deep copy when casting
function target = copy(source, target)
    target.msbLength = source.msbLength;
    target.lsbLength = source.lsbLength;
    target.apiId = source.apiId;
    target.checksum = source.checksum;
    target.frameData = source.frameData;
    target.isValid = source.isValid;
end

