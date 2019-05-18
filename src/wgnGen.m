function [ noise ] = wgnGen(sys, Hd, noiseLen)
% @intro, ��������������
% sys@param, ϵͳ�����ṹ��
% Hd@param, �˲����ṹ��
% noiseLen@param, ��������
% noise@retrval, ��������


% ���ɸ�˹������
NOISE_POWER = sys.NOISE_POWER;
unFiltNoise = wgn(noiseLen, 1, NOISE_POWER, 'dBm', 'complex');

% ���ɴ����������Ƴ���Ϊ�˲�����������ʱ
filtDelay = Hd.filtDelay;
unFiltNoise = [filtDelay; zeros(filtDelay, 1)];
filtNoise = filter(Hd.Hd, unFiltNoise);
filtNoise = filtNoise(filtDelay+1 : end);   

% ���������������ʵ�ָ�����ʣ�NOISE_POWER��
filtNoisePower = sum(abs(filtNoise) .^ 2) / length(noiseLen);   % �����˲������������
pnVal = (10 ^ (NOISE_POWER / 10)) / 1000;                       % dBm to Watt.
pscale = sqrt(pnVal / filtNoisePower);                          % ���ʱ�������
noise = filtNoise * pscale;                                % ���ź�ָ���������ʵ�����

end

