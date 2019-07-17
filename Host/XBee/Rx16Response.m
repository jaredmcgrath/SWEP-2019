classdef Rx16Response < RxResponse
    % Represents a Series 1 16-bit address RX packet
    
    properties (Constant)
        rssiOffset = XBeeConst.RX_16_RSSI_OFFSET;
        addressWidth = 2;
    end
end
