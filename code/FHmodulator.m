function [msgFHmodulatedMat] = FHmodulator(samp , msgModulatedMat , fhTable , fs)
% @function, [msgFHmodulatedMat] = FHmodulator(samp , msgModulatedMat , fhTable , fs)
% @intro, 根据跳频表跳频
% samp@param, 过采样率
% msgModulatedMat@param, 已调制矩阵(行：跳频点数，列：每个频点下的复基带调制信号)
% fhTable@param, 跳频表；每一个频点对应一个符号(所以msgModulatedMat的行数等于fhTable的元素个数)
% fs@param, 采样率
% msgFHmodulatedMat@retval, 跳频后的复信号


[hopNum , sampsPerHop] = size(msgModulatedMat);
% 构造时间序列
t = [1:numel(msgModulatedMat)] / fs;
tMat = reshape(t , sampsPerHop , hopNum);
tMat = tMat';

% tMat = ones(hopNum , sampsPerHop) .* (1 : 1 : sampsPerHop) / samp;

% 跳频
fhTable = fhTable';
fhMat = exp(1j * 2*pi *  fhTable .* tMat) ;     % 跳频频率
msgFHmodulatedMat = fhMat .* msgModulatedMat;   % 跳频

end

