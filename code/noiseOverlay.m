function [ signalNoisy ] = noiseOverlay(sys, Hd, signal, noise, snr)
% @intro, Ϊ�źŵ�������
% sys@param, ϵͳ�����ṹ��
% Hd@param, �˲����ṹ��
% signal@param, �������������ź�
% noise@param, ��������
% signalNoisy@retrval, ����������Ĵ����ź�

NOISE_POWER = sys.NOISE_POWER;      % ��������

% �ź��˲����Ƴ��˲�����������ʱ
filtDelay = Hd.filtDelay;                       % �˲����������ʱ
signal = [signal; zeros(filtDelay, 1)];
filtSignal = filter(Hd.Hd , signal);               % �ź��˲�
filtSignal = filtSignal(filtDelay+1 : end);     % �Ƴ���ʱ

filtSignalPower = sum(abs(filtSignal) .^ 2) / length(filtSignal);   % �˲����źŹ���

pnVal = (10 ^ (NOISE_POWER / 10)) / 1000;                           % dBm to Watt.
dbVal = 10^(snr / 10);  % dBת�ɷ�dB��ʽ

psVal = pnVal * dbVal;  % �ź�ʵ�ʹ���

pscale = sqrt(psVal / filtSignalPower);                             % ���ʱ�������
pscaledSignal = pscale * filtSignal;                                % �����ʱ��������źŷ���

% ��������
signalNoisy = pscaledSignal + noise;

end

