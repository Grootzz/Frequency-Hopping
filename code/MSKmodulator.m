function [ NRZMatrix , modulateMatrix ] = MSKmodulator(samp, msgMatrix)
% @function, [ NRZMatrix , modulateMatrix ] = MSKmodulator(samp, msgMatrix)
% @intro, MSK调制器
% samp@param, 过采样率
% msgMatrix@param, 待调制信息矩阵(行：符号数，列：每个符号的复基带调制信号)
% NRZMatrix@retrvl, 双极性码矩阵(行：符号数，列：每个符号采样后的信号)
% modulateMatrix@retrvl, 已调制矩阵(行：符号数，列：每个符号的复基带调制信号)

[HOP_NUM, BIT_NUM] = size(msgMatrix);                % 获取符号数和每个符号的bit数

modulateMatrix = zeros(HOP_NUM , BIT_NUM*samp);      % 用于存储所有CCSK码字的调制信息
NRZMatrix = zeros(HOP_NUM , BIT_NUM*samp);           % 用于存储NRZ

% 调制
for ii = 1 : HOP_NUM
    [NRZTmp , phaseTraceTmp] = phaseTraceGenerator(samp , msgMatrix(ii, :));
    NRZMatrix(ii , :) = NRZTmp;
    modulateMatrix(ii , :) = exp(1j*phaseTraceTmp); % 复基带调制
end

end

