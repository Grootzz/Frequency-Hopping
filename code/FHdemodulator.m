function [ rcvBBmat ] = FHdemodulator(samp , rcvMat , fhTable , fs)
% @function, [ rcvBBmat ] = FHdemodulator(samp , rcvMat , fhTable)
% @intro, ������Ƶ����Ƶ
% samp@param, ��������
% rcvMat@param, �ѵ��ƾ���(�У���Ƶ�������У�ÿ����Ƶ���µĸ����������ź�)
% fhTable@param, ��Ƶ��ÿһ��Ƶ���Ӧһ������(����rcvMat����������fhTable��Ԫ�ظ���)
% fs@param, ������
% rcvBBmat@retval, ��Ƶ��ĸ��ź�

[hopNum , sampsPerHop] = size(rcvMat);
% ����ʱ������
t = [1:numel(rcvMat)] / fs;
tMat = reshape(t , sampsPerHop , hopNum);
tMat = tMat';

% ����
fhMat = exp(1j * 2*pi * -fhTable' .* tMat) ;        % ��ƵƵ��
rcvBBmat = fhMat .* rcvMat;                         % ����

end

