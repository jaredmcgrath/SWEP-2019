classdef XBeeConst
    % All the constants needed for the XBee, in a named format
    % TODO: Ensure all these values (indexes and lengths) are proper
    % because MATLAB uses 1-based indexing
    
    properties (Constant)
        % Special bytes
        START_BYTE = 126
        ESCAPE = 125
        % Reserved bytes that must be escaped
        XON = 17
        XOFF = 19
        
        % Special addresses
        BROADCAST_ADDRESS = 65535
        
        % Non-variable lengths/indexes for specific packets
        TX_16_API_LENGTH = 4
        TX_64_API_LENGTH = 10
        % Not sure if correct, matlab indexes are weird
        AT_COMMAND_API_LENGTH = 3
        REMOTE_AT_COMMAND_API_LENGTH = 14
        % start + length(2) + api + frame id + checksum bytes
        PACKET_OVERHEAD_LENGTH = 6
        % API byte is always fourth byte
        API_ID_INDEX = 4
        % RSSI is in different position for 16/64 bit requests
        RX_16_RSSI_OFFSET = 3
        RX_64_RSSI_OFFSET = 9
        
        % Frame Types
        TX_64_REQUEST = 0
        TX_16_REQUEST = 1
        AT_COMMAND_REQUEST = 8
        AT_COMMAND_QUEUE_REQUEST = 9
        REMOTE_AT_REQUEST = 23
        RX_64_RESPONSE = 128
        RX_16_RESPONSE = 129
        RX_64_IO_RESPONSE = 130
        RX_16_IO_RESPONSE = 131
        AT_RESPONSE = 136
        TX_STATUS_RESPONSE = 137
        AT_COMMAND_RESPONSE = 136
        REMOTE_AT_COMMAND_RESPONSE = 151
        DEFAULT_FRAME_ID = 1
        
        % TX Statuses
        SUCCESS = 0
        CCA_FAILURE = 2
        INVALID_DESTINATION_ENDPOINT_SUCCESS = 21
        NETWORK_ACK_FAILURE = 33
        NOT_JOINED_TO_NETWORK = 34
        SELF_ADDRESSED = 35
        ADDRESS_NOT_FOUND = 36
        ROUTE_NOT_FOUND = 37
        PAYLOAD_TOO_LARGE = 116
        
        % AT Command Statuses
        AT_OK = 0
        AT_ERROR = 1
        AT_INVALID_COMMAND = 2
        AT_INVALID_PARAMETER = 3
        AT_NO_RESPONSE = 4
        
        % Options for Tx request
        ACK_OPTION = 0
        DISABLE_ACK_OPTION = 1
        BROADCAST_OPTION = 4
        
    end
end