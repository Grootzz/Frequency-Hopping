function [ noise ] = wgnGen(sys, Hd, noiseLen)
% @intro, 带限噪声生成器
% sys@param, 系统参数结构体
% Hd@param, 滤波器结构体
% noiseLen@param, 噪声点数
% noise@retrval, 带限噪声


% 生成高斯白噪声
NOISE_POWER = sys.NOISE_POWER;
unFiltNoise = wgn(noiseLen, 1, NOISE_POWER, 'dBm', 'complex');

% 生成带限噪声并移除因为滤波器产生的延时
filtDelay = Hd.filtDelay;
unFiltNoise = [filtDelay; zeros(filtDelay, 1)];
filtNoise = filter(Hd.Hd, unFiltNoise);
filtNoise = filtNoise(filtDelay+1 : end);   

% 调整带限噪声功率到指定功率（NOISE_POWER）
filtNoisePower = sum(abs(filtNoise) .^ 2) / length(noiseLen);   % 计算滤波后的噪声功率
pnVal = (10 ^ (NOISE_POWER / 10)) / 1000;                       % dBm to Watt.
pscale = sqrt(pnVal / filtNoisePower);                          % 功率比例缩放
noise = filtNoise * pscale;                                % 缩放后到指定噪声功率的噪声

end

