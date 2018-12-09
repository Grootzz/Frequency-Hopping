function [ signalNoisy ] = noiseOverlay(sys, Hd, signal, noise, snr)
% @intro, 为信号叠加噪声
% sys@param, 系统参数结构体
% Hd@param, 滤波器结构体
% signal@param, 待叠加噪声的信号
% noise@param, 带限噪声
% signalNoisy@retrval, 叠加噪声后的带限信号

NOISE_POWER = sys.NOISE_POWER;      % 噪声功率

% 信号滤波并移除滤波器带来的延时
filtDelay = Hd.filtDelay;                       % 滤波器引入的延时
signal = [signal; zeros(filtDelay, 1)];
filtSignal = filter(Hd.Hd , signal);               % 信号滤波
filtSignal = filtSignal(filtDelay+1 : end);     % 移除延时

filtSignalPower = sum(abs(filtSignal) .^ 2) / length(filtSignal);   % 滤波后信号功率

pnVal = (10 ^ (NOISE_POWER / 10)) / 1000;                           % dBm to Watt.
dbVal = 10^(snr / 10);  % dB转成非dB形式

psVal = pnVal * dbVal;  % 信号实际功率

pscale = sqrt(psVal / filtSignalPower);                             % 功率比例缩放
pscaledSignal = pscale * filtSignal;                                % 按功率比例缩放信号幅度

% 叠加噪声
signalNoisy = pscaledSignal + noise;

end

