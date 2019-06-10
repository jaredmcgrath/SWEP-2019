function sendControlInputs(config, tags, controlInput)
%% sendControlInputs
% Sends the control inputs to bots and tells them to go
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   tags
%     Character vector of bot tag(s) to send input(s) to
%   controlInput
%     n-by-2 vector of control inputs (-255<=input<=255) in 
%     [L1 R1; L2 R2; ... ] format
%
% Returns:
%   N/A

for i=1:length(tags)
    sendInstruction(config, 'SET_M_L', tags(i), controlInput(i,1));
    sendInstruction(config, 'SET_M_R', tags(i), controlInput(i,2));
end
sendInstruction(config, 'G_GO');
