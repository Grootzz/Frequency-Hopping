%% 简易跳频系统误比特率统计分析
% 调制-->跳频-->信道-->解跳-->解调-->误码分析

clc;clear;close all;

%% 系统参数设置
Rb = 5e4;                       % 速率：50Kb/s
Tb = 1 / Rb;                    % bit间隔
hopping = 1000;                 % 跳频速率
bitsPerHop = Rb / hopping;      % 每跳bit数目（必须为整数）
samp = 20;                     % 过采样倍数
fs = samp*Rb;                   % 采样率
BW = 5e6;                       % 跳频带宽
freqNum = floor(BW / (Rb*4));   % 跳频频点数目
freqInterval = BW / freqNum;    % 频点间隔
freqSeq = ([0:freqNum-1] - floor(freqNum/2)) * freqInterval;   % 跳频频点序列
carrier = 3e6;                  % 跳频中心频率
carrierSeq = carrier + freqSeq; % 发送时跳频频点序列

%% 传输信息参数设置
SYNC_BIT_NUM = 50;                                  % 同步bit数目
PACKET_NUM = 3;                                     % 每一帧的包数目
MSG_BIT_NUM = 1024*PACKET_NUM;                      % 消息bit数目
TX_BIT_NUM = SYNC_BIT_NUM + MSG_BIT_NUM;            % 需要发送的bit数目

HOP_NUM = ceil(TX_BIT_NUM / bitsPerHop);            % 发送所有的bit需要的跳频点数
%（由于总的发送bit数目不一定是每跳bit数目bitsPerHop的整数倍，所以，构造为bitsPerHop的整数倍，在解调后去除多余bit即可）
EXCEED_BIT = HOP_NUM * bitsPerHop - TX_BIT_NUM;     % 多余的bit

%% 构造发送序列
SYNC = randi([0 ,1] , 1 , SYNC_BIT_NUM);                        % 同步二进制序列（用一串随机序列代替）
MSG = randi([0,1] ,1 ,HOP_NUM*bitsPerHop - SYNC_BIT_NUM);       % 消息字符号
TX_BIT = [SYNC , MSG];                                          % 构造整个发送bit序列
TX_BIT_MAT = reshape(TX_BIT , bitsPerHop , HOP_NUM);            % 将待发送序列转成一个矩阵，每一行是1个跳频频点下需要发送的bit数目
TX_BIT_MAT = TX_BIT_MAT';                                       % 行：跳数，列: 每跳对应的bit序列

%% 调制
[biNRZ , msgModMatrix]  = MSKmodulator(samp, TX_BIT_MAT);            % 复基带调制矩阵

%% 误比特分析参数设置
frameNum = 1000;                  % 传输帧数目
snr = 0:18;                     % 信噪比
ber = zeros(1 , length(snr));   % 误bit率
berPacket = zeros(1 , length(snr));   % 误包率

%% 误bit率分析（通过在不同的信噪比下传输多个帧做统计分析，可以通过增加传输帧数目获取更加精确的误比特率；更改信噪比获取不同信噪比下的性能）
for ii = 1 : length(snr)
    sumErrBit = 0;
    sumErrPacket = 0;
    for jj = 1 : frameNum
        % 跳频
        fhIndex = randi([1 , freqNum] , 1 , HOP_NUM);                           % 根据跳频点数生成随机频点序列索引
        txFHtable = carrierSeq(fhIndex);                                        % 根据随机频点序列索引生成跳频频点（收发频点保持一致才可以解跳）
        txFHmodulatedMat = FHmodulator(samp , msgModMatrix , txFHtable , fs);	% 跳频后的信号
        
        % 信道
        txFHmodulated = reshape(txFHmodulatedMat' , 1 , numel(txFHmodulatedMat));       % 将矩阵形式的信号转化为实际的1维信号
        rcvNoisy = awgn(txFHmodulated , snr(ii));                                       % 添加噪声
        rcvNoisyMat = reshape(rcvNoisy , numel(txFHmodulatedMat) / HOP_NUM , HOP_NUM);  % 为了便于后面的解跳/解跳操作, 将1维信号还原为矩阵形式
        rcvNoisyMat = rcvNoisyMat';                                                     % 行：跳数，列: 每跳对应的带噪声的调制信号
        
        % 解跳
        rcvBBmat = FHdemodulator(samp , rcvNoisyMat , txFHtable , fs);
        
        % 差分解调
        rcvBB1dim = reshape(rcvBBmat' , 1 , numel(rcvBBmat));                   % 还原信号为连续形式
        rcvBBsamp = reshape(rcvBB1dim , samp , numel(rcvBB1dim)/samp);          % 转换成每samp一个单元(即以bit为采样单元)
        dmdBit = imag(conj(rcvBBsamp(samp,:)) .* rcvBBsamp(1,:)) >0;            % 差分解调
        dmdBit = dmdBit(1:end-EXCEED_BIT);                                      % 根据冗余bit数目去除多余bit
        orignalBit = TX_BIT(1:end-EXCEED_BIT);                                  % 根据冗余bit数目去除发送序列中多余的bit
        
        % 计算误bit数(包括同步序列和消息序列，不包括冗余序列)
        errBitNum = sum(orignalBit~=dmdBit);
        sumErrBit = sumErrBit + errBitNum;
        
        % 计算误包率
        orignalPacket = orignalBit(SYNC_BIT_NUM+1 : end);
        dmdPacket = dmdBit(SYNC_BIT_NUM+1 : end);        
        orignalPacketMat = reshape(orignalPacket , MSG_BIT_NUM/PACKET_NUM , PACKET_NUM);    % bit序列转换成包，每一列一包
        dmdPacketMat = reshape(dmdPacket , MSG_BIT_NUM/PACKET_NUM , PACKET_NUM);            % bit序列转换成包，每一列一包
        % 统计误包(比较一包里面的bit是否与发送端向相同，不同加1，相同加0)
        sumErrPacket = ...
            (sum(orignalPacketMat(:, 1) ~= dmdPacketMat(:, 1))>0)+...
            (sum(orignalPacketMat(:, 2) ~= dmdPacketMat(:, 2))>0)+...
            (sum(orignalPacketMat(:, 3) ~= dmdPacketMat(:, 3))>0)+sumErrPacket;
        
        [ii jj]
    end 
    % 计算误bit率
    ber(ii) = sumErrBit / (frameNum*TX_BIT_NUM);
    berPacket(ii) = sumErrPacket/(frameNum*PACKET_NUM);
end
%% 误bit率曲线
semilogy(snr  , ber); xlabel('SNR/dB')  ; ylabel('误码率'); grid on ;title(['总传输帧数: ' , num2str(frameNum)]);
%% 误包率曲线
figure(2)
semilogy(snr  , berPacket); xlabel('SNR/dB')  ; ylabel('误包率'); grid on ;title(['总传输包数: ' , num2str(frameNum*PACKET_NUM)]);


