function [ output_args ] = fftTool( X , Fs , info )
% @intro, 对信号X做FFT变换
% Fs@param, 采样率
% X@param, 输入数据

L = length(X);      % Signal length

n = 2^nextpow2(L);

Y = fft(X,n);

f = Fs*(0:(n/2))/n;
P = abs(Y/n);
% P = 10*log10((abs(Y).^2/n)/max(abs(Y).^2/n));

plot(f,P(1:n/2+1)) ;
title(strcat(info,' in Frequency Domain'));
xlabel('Frequency (f)');
ylabel('|P(f)|');

end

