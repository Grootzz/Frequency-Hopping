function [ rcvBBmat ] = FHdemodulator(samp , rcvMat , fhTable , fs)
% @function, [ rcvBBmat ] = FHdemodulator(samp , rcvMat , fhTable)
% @intro, 根据跳频表跳频
% samp@param, 过采样率
% rcvMat@param, 已调制矩阵(行：跳频点数，列：每个跳频点下的复基带调制信号)
% fhTable@param, 跳频表；每一个频点对应一个符号(所以rcvMat的行数等于fhTable的元素个数)
% fs@param, 采样率
% rcvBBmat@retval, 跳频后的复信号

[hopNum , sampsPerHop] = size(rcvMat);
% 构造时间序列
t = [1:numel(rcvMat)] / fs;
tMat = reshape(t , sampsPerHop , hopNum);
tMat = tMat';

% 解跳
fhTableMat = zeros(hopNum , sampsPerHop);
for ii = 1:hopNum
    fhTableMat(ii , :) = -fhTable(ii);
end
fhMat = exp(1j * 2*pi * fhTableMat .* tMat) ;        % 跳频频率
rcvBBmat = fhMat .* rcvMat;                         % 解跳

end

