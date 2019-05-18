function [ NRZMatrix , modulateMatrix ] = MSKmodulator(samp, msgMatrix)
% @function, [ NRZMatrix , modulateMatrix ] = MSKmodulator(samp, msgMatrix)
% @intro, MSK������
% samp@param, ��������
% msgMatrix@param, ��������Ϣ����(�У����������У�ÿ�����ŵĸ����������ź�)
% NRZMatrix@retrvl, ˫���������(�У����������У�ÿ�����Ų�������ź�)
% modulateMatrix@retrvl, �ѵ��ƾ���(�У����������У�ÿ�����ŵĸ����������ź�)

[HOP_NUM, BIT_NUM] = size(msgMatrix);                % ��ȡ��������ÿ�����ŵ�bit��

modulateMatrix = zeros(HOP_NUM , BIT_NUM*samp);      % ���ڴ洢����CCSK���ֵĵ�����Ϣ
NRZMatrix = zeros(HOP_NUM , BIT_NUM*samp);           % ���ڴ洢NRZ

% ����
for ii = 1 : HOP_NUM
    [NRZTmp , phaseTraceTmp] = phaseTraceGenerator(samp , msgMatrix(ii, :));
    NRZMatrix(ii , :) = NRZTmp;
    modulateMatrix(ii , :) = exp(1j*phaseTraceTmp); % ����������
end

end

