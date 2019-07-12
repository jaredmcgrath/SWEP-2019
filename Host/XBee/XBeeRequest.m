classdef (Abstract) XBeeRequest
    % Super class of all XBee requests (TX packets)
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
        frameId(1,1) uint8 = XBeeConst.DEFAULT_FRAME_ID
    end
    
    % Ensure any concrete subclasses specify an apiId
    properties (Abstract, Constant)
        apiId(1,1) uint8
    end
    
    properties (Dependent, SetAccess = private)
        msbLength(1,1) uint8
        lsbLength(1,1) uint8
        checksum(1,1) uint8
    end
    
    % frameData should be constructed from other API-specific data
    properties (Abstract, Dependent, SetAccess = protected)
        frameData(1,:) uint8
    end
    
    methods
        function msbLength = get.msbLength(obj)
            msbLength = uint8(length(obj.frameData)*pow2(-8));
        end
        
        function lsbLength = get.lsbLength(obj)
            lsbLength = uint8(bitand(length(obj.frameData),255));
        end
        
        function checksum = get.checksum(obj)
            temp = mod(uint16(obj.frameId) + uint16(obj.apiId) + ...
                sum(obj.frameData),256);
            % 0xFF - sum
            checksum = 255 - temp;
        end
        
        % Translates a packet to a valid series of bytes
        function packet = toSendFormat(obj)
            body = escape([obj.msbLength obj.lsbLength obj.apiId ...
                obj.frameId obj.frameData obj.checksum]);
            packet = [XBeeConst.START_BYTE body];
        end
    end
end

% Helper function to escape characters properly
function escapedText = escape(text)
    escapeChars = [XBeeConst.START_BYTE XBeeConst.ESCAPE XBeeConst.XON...
        XBeeConst.XOFF];
    escapedText = '';
    for c = text
        if ismember(c, escapeChars)
            % add escape char (0x7D), do XOR(c,0x20)
            escapedText = [escapedText XBeeConst.ESCAPE bitxor(c,32)];
        else
            escapedText = [escapedText c];
        end
    end
end