%% ������Ƶϵͳ������ʾ
% ����-->��Ƶ-->�ŵ�-->����-->���-->�������

clc;clear;close all;

%% ϵͳ��������
Rb = 5e4;                       % ���ʣ�50Kb/s
Tb = 1 / Rb;                    % bit���
hopping = 1000;                 % ��Ƶ����
bitsPerHop = Rb / hopping;      % ÿ��bit��Ŀ������Ϊ������
samp = 200;                     % ����������
fs = samp*Rb;                   % ������
BW = 5e6;                       % ��Ƶ����
freqNum = floor(BW / (Rb*4));   % ��ƵƵ����Ŀ
freqInterval = BW / freqNum;    % Ƶ����
freqSeq = ([0:freqNum-1] - floor(freqNum/2)) * freqInterval;   % ��ƵƵ������
carrier = 3e6;                  % ��Ƶ����Ƶ��
carrierSeq = carrier + freqSeq; % ����ʱ��ƵƵ������

%% ������Ϣ��������
SYNC_BIT_NUM = 40;                                  % ͬ��bit��Ŀ
MSG_BIT_NUM = 1024;                                 % ��Ϣbit��Ŀ
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

%% ��Ƶ
fhIndex = randi([1 , freqNum] , 1 , HOP_NUM);                           % ������Ƶ�����������Ƶ����������
txFHtable = carrierSeq(fhIndex);                                        % �������Ƶ����������������ƵƵ�㣨�շ�Ƶ�㱣��һ�²ſ��Խ�����
txFHmodulatedMat = FHmodulator(samp , msgModMatrix , txFHtable , fs);	% ��Ƶ����źţ�������ͬ���뾫ͬ����

%% �ŵ�
snr = 1;
txFHmodulated = reshape(txFHmodulatedMat' , 1 , numel(txFHmodulatedMat));       % ��������ʽ���ź�ת��Ϊʵ�ʵ�1ά�ź�
rcvNoisy = awgn(txFHmodulated , snr);                                           % �������
rcvNoisyMat = reshape(rcvNoisy , numel(txFHmodulatedMat) / HOP_NUM , HOP_NUM);  % Ϊ�˱��ں���Ľ���/��������, ��1ά�źŻ�ԭΪ������ʽ
rcvNoisyMat = rcvNoisyMat';                                                     % �У���������: ÿ����Ӧ�Ĵ������ĵ����ź�

%% ����
rcvBBmat = FHdemodulator(samp , rcvNoisyMat , txFHtable , fs);

%% ��ֽ��
rcvBB1dim = reshape(rcvBBmat' , 1 , numel(rcvBBmat));                   % ��ԭ�ź�Ϊ������ʽ
rcvBBsamp = reshape(rcvBB1dim , samp , numel(rcvBB1dim)/samp);          % ת����ÿsampһ����Ԫ(����bitΪ������Ԫ)
dmdBit = imag(conj(rcvBBsamp(samp,:)) .* rcvBBsamp(1,:)) >0;            % ��ֽ��
dmdBit = dmdBit(1:end-EXCEED_BIT);                                      % ��������bit��Ŀȥ������bit
orignalBit = TX_BIT(1:end-EXCEED_BIT);                                  % ��������bit��Ŀȥ�����������ж����bit

%% ������bit��
errBitNum = sum(orignalBit~=dmdBit);                                    


%% Ƶ��������
figure(1)
bb = reshape(biNRZ' , 1 , numel(biNRZ));    % ����
fftshow( bb , fs , 'single'); xlabel('f/Hz'); ylabel('����/dB'); title('�����ź�');
figure(2)
fftTool( bb , fs , '�����ź�'); xlabel('f/Hz'); ylabel('����');
figure(3)
plot((0:length(txFHmodulated)-1)/length(txFHmodulated)*fs , abs(fft(txFHmodulated))); xlabel('f/Hz'); ylabel('����'); title('��Ƶ�ź�Ƶ��(�����ŵ�ǰ)');
figure(4)
plot((0:length(rcvNoisy)-1)/length(rcvNoisy)*fs , abs(fft(rcvNoisy))); xlabel('f/Hz'); ylabel('����'); title('��Ƶ�ź�Ƶ��(�����ŵ���)');

