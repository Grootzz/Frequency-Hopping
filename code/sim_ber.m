%% ������Ƶϵͳ�������ͳ�Ʒ���
% ����-->��Ƶ-->�ŵ�-->����-->���-->�������

clc;clear;close all;

%% ϵͳ��������
Rb = 5e4;                       % ���ʣ�50Kb/s
Tb = 1 / Rb;                    % bit���
hopping = 1000;                 % ��Ƶ����
bitsPerHop = Rb / hopping;      % ÿ��bit��Ŀ������Ϊ������
samp = 20;                     % ����������
fs = samp*Rb;                   % ������
BW = 5e6;                       % ��Ƶ����
freqNum = floor(BW / (Rb*4));   % ��ƵƵ����Ŀ
freqInterval = BW / freqNum;    % Ƶ����
freqSeq = ([0:freqNum-1] - floor(freqNum/2)) * freqInterval;   % ��ƵƵ������
carrier = 3e6;                  % ��Ƶ����Ƶ��
carrierSeq = carrier + freqSeq; % ����ʱ��ƵƵ������

%% ������Ϣ��������
SYNC_BIT_NUM = 50;                                  % ͬ��bit��Ŀ
PACKET_NUM = 3;                                     % ÿһ֡�İ���Ŀ
MSG_BIT_NUM = 1024*PACKET_NUM;                      % ��Ϣbit��Ŀ
TX_BIT_NUM = SYNC_BIT_NUM + MSG_BIT_NUM;            % ��Ҫ���͵�bit��Ŀ

HOP_NUM = ceil(TX_BIT_NUM / bitsPerHop);            % �������е�bit��Ҫ����Ƶ����
%�������ܵķ���bit��Ŀ��һ����ÿ��bit��ĿbitsPerHop�������������ԣ�����ΪbitsPerHop�����������ڽ����ȥ������bit���ɣ�
EXCEED_BIT = HOP_NUM * bitsPerHop - TX_BIT_NUM;     % �����bit

%% ���췢������
SYNC = randi([0 ,1] , 1 , SYNC_BIT_NUM);                        % ͬ�����������У���һ��������д��棩
MSG = randi([0,1] ,1 ,HOP_NUM*bitsPerHop - SYNC_BIT_NUM);       % ��Ϣ�ַ���
TX_BIT = [SYNC , MSG];                                          % ������������bit����
TX_BIT_MAT = reshape(TX_BIT , bitsPerHop , HOP_NUM);            % ������������ת��һ������ÿһ����1����ƵƵ������Ҫ���͵�bit��Ŀ
TX_BIT_MAT = TX_BIT_MAT';                                       % �У���������: ÿ����Ӧ��bit����

%% ����
[biNRZ , msgModMatrix]  = MSKmodulator(samp, TX_BIT_MAT);            % ���������ƾ���

%% ����ط�����������
frameNum = 1000;                  % ����֡��Ŀ
snr = 0:18;                     % �����
ber = zeros(1 , length(snr));   % ��bit��
berPacket = zeros(1 , length(snr));   % �����

%% ��bit�ʷ�����ͨ���ڲ�ͬ��������´�����֡��ͳ�Ʒ���������ͨ�����Ӵ���֡��Ŀ��ȡ���Ӿ�ȷ��������ʣ���������Ȼ�ȡ��ͬ������µ����ܣ�
for ii = 1 : length(snr)
    sumErrBit = 0;
    sumErrPacket = 0;
    for jj = 1 : frameNum
        % ��Ƶ
        fhIndex = randi([1 , freqNum] , 1 , HOP_NUM);                           % ������Ƶ�����������Ƶ����������
        txFHtable = carrierSeq(fhIndex);                                        % �������Ƶ����������������ƵƵ�㣨�շ�Ƶ�㱣��һ�²ſ��Խ�����
        txFHmodulatedMat = FHmodulator(samp , msgModMatrix , txFHtable , fs);	% ��Ƶ����ź�
        
        % �ŵ�
        txFHmodulated = reshape(txFHmodulatedMat' , 1 , numel(txFHmodulatedMat));       % ��������ʽ���ź�ת��Ϊʵ�ʵ�1ά�ź�
        rcvNoisy = awgn(txFHmodulated , snr(ii));                                       % �������
        rcvNoisyMat = reshape(rcvNoisy , numel(txFHmodulatedMat) / HOP_NUM , HOP_NUM);  % Ϊ�˱��ں���Ľ���/��������, ��1ά�źŻ�ԭΪ������ʽ
        rcvNoisyMat = rcvNoisyMat';                                                     % �У���������: ÿ����Ӧ�Ĵ������ĵ����ź�
        
        % ����
        rcvBBmat = FHdemodulator(samp , rcvNoisyMat , txFHtable , fs);
        
        % ��ֽ��
        rcvBB1dim = reshape(rcvBBmat' , 1 , numel(rcvBBmat));                   % ��ԭ�ź�Ϊ������ʽ
        rcvBBsamp = reshape(rcvBB1dim , samp , numel(rcvBB1dim)/samp);          % ת����ÿsampһ����Ԫ(����bitΪ������Ԫ)
        dmdBit = imag(conj(rcvBBsamp(samp,:)) .* rcvBBsamp(1,:)) >0;            % ��ֽ��
        dmdBit = dmdBit(1:end-EXCEED_BIT);                                      % ��������bit��Ŀȥ������bit
        orignalBit = TX_BIT(1:end-EXCEED_BIT);                                  % ��������bit��Ŀȥ�����������ж����bit
        
        % ������bit��(����ͬ�����к���Ϣ���У���������������)
        errBitNum = sum(orignalBit~=dmdBit);
        sumErrBit = sumErrBit + errBitNum;
        
        % ���������
        orignalPacket = orignalBit(SYNC_BIT_NUM+1 : end);
        dmdPacket = dmdBit(SYNC_BIT_NUM+1 : end);        
        orignalPacketMat = reshape(orignalPacket , MSG_BIT_NUM/PACKET_NUM , PACKET_NUM);    % bit����ת���ɰ���ÿһ��һ��
        dmdPacketMat = reshape(dmdPacket , MSG_BIT_NUM/PACKET_NUM , PACKET_NUM);            % bit����ת���ɰ���ÿһ��һ��
        % ͳ�����(�Ƚ�һ�������bit�Ƿ��뷢�Ͷ�����ͬ����ͬ��1����ͬ��0)
        sumErrPacket = ...
            (sum(orignalPacketMat(:, 1) ~= dmdPacketMat(:, 1))>0)+...
            (sum(orignalPacketMat(:, 2) ~= dmdPacketMat(:, 2))>0)+...
            (sum(orignalPacketMat(:, 3) ~= dmdPacketMat(:, 3))>0)+sumErrPacket;
        
        [ii jj]
    end 
    % ������bit��
    ber(ii) = sumErrBit / (frameNum*TX_BIT_NUM);
    berPacket(ii) = sumErrPacket/(frameNum*PACKET_NUM);
end
%% ��bit������
semilogy(snr  , ber); xlabel('SNR/dB')  ; ylabel('������'); grid on ;title(['�ܴ���֡��: ' , num2str(frameNum)]);
%% ���������
figure(2)
semilogy(snr  , berPacket); xlabel('SNR/dB')  ; ylabel('�����'); grid on ;title(['�ܴ������: ' , num2str(frameNum*PACKET_NUM)]);


