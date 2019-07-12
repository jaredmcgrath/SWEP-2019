classdef Rx64Response < RxResponse
    % Represents a Series 1 64-bit address RX packet
    
    properties (Constant)
        rssiOffset = XBeeConst.RX_64_RSSI_OFFSET;
        addressWidth = 8;
    end
end