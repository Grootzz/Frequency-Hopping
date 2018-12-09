function [msgFHmodulatedMat] = FHmodulator(samp , msgModulatedMat , fhTable , fs)
% @function, [msgFHmodulatedMat] = FHmodulator(samp , msgModulatedMat , fhTable , fs)
% @intro, ������Ƶ����Ƶ
% samp@param, ��������
% msgModulatedMat@param, �ѵ��ƾ���(�У���Ƶ�������У�ÿ��Ƶ���µĸ����������ź�)
% fhTable@param, ��Ƶ��ÿһ��Ƶ���Ӧһ������(����msgModulatedMat����������fhTable��Ԫ�ظ���)
% fs@param, ������
% msgFHmodulatedMat@retval, ��Ƶ��ĸ��ź�


[hopNum , sampsPerHop] = size(msgModulatedMat);
% ����ʱ������
t = [1:numel(msgModulatedMat)] / fs;
tMat = reshape(t , sampsPerHop , hopNum);
tMat = tMat';

% tMat = ones(hopNum , sampsPerHop) .* (1 : 1 : sampsPerHop) / samp;

% ��Ƶ
fhTable = fhTable';
fhMat = exp(1j * 2*pi *  fhTable .* tMat) ;     % ��ƵƵ��
msgFHmodulatedMat = fhMat .* msgModulatedMat;   % ��Ƶ

end

