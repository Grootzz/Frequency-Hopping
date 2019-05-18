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

% ��Ƶ
fhTableMat = zeros(hopNum , sampsPerHop);
for ii = 1:hopNum
    fhTableMat(ii , :) = fhTable(ii);
end
fhMat = exp(1j * 2*pi *  fhTableMat .* tMat) ;     % ��ƵƵ��
msgFHmodulatedMat = fhMat .* msgModulatedMat;   % ��Ƶ

end

