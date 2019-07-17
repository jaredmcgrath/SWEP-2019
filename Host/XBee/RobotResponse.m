classdef RobotResponse < Rx16Response
    % RobotResponse interprets an Rx16Response's data as specified in the
    % communication protocol. Mostly used as a convenience object to
    % cleanup code.
    % Note that this class inherits the apiId of Rx16Response, equal to
    % XBeeConst.RX_16_RESPONSE
    
    properties (Dependent, SetAccess = private)
        % TODO: Check for endianness
        % Bot's id is indicated in the address
        id(1,1) uint8
        % The instruction the bot is responding to is the first byte in the
        % data
        instruction(1,1) uint8
        % Remaining width is the actual data the bot sent
        responseData(1,:) uint8
    end
    
    methods
        function id = get.id(obj)
            % Take the bot's ID to be the LSB of the 16-bit address
            id = obj.address(end);
        end
        
        function ins = get.instruction(obj)
            ins = obj.data(1);
        end
        
        function data = get.responseData(obj)
            data = obj.data(2:end);
        end
    end
    
end