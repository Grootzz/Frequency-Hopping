function [msgNRZ , phaseTrace] = phaseTraceGenerator(samp , msg)
% @funciton, [msgNRZ , phaseTrace] = phaseTraceGenerator(samp , msg)
% @brief, generate phase trace for CPM modulation
% samp@param, oversampling ratio
% msg@param, bit array
% msgNRZ@retrvl, msgNRZ, msg NRZ array
% phaseTrace@retrvl, phaseTrace, phase trace during bit array duration

h = 1/2;

msgNRZ = [];
phaseTrace = [];

msgLen = length(msg);                       % the length of msg

g_msk = ones(1,samp);                       % g(t) for MSK
q_msk = [1:1:samp]*(1/2) / samp;            % q(t) for MSK

msg2Rec = msg*2 - 1 ;                       % convert msg to REC code

for ii=1:msgLen
    msgNRZ = [msgNRZ , g_msk*msg2Rec(ii)];  % generate NRZ waveform from msg REC code
end

%% compute phase trace for MSK
phaseInitValue = 0;
MSKphaseTrace = [];

% generate NRZ waveform and phase trace
for ii=1:1:msgLen
    MSKphaseTrace = [MSKphaseTrace , phaseInitValue + 2*pi*h*msg2Rec(ii)*q_msk];  % generate phase trace
    phaseInitValue = phaseInitValue + pi*h*msg2Rec(ii);
end
phaseTrace = MSKphaseTrace;    % return MSK phase trace

end

