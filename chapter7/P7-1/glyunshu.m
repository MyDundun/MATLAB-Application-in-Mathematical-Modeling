function main()
clc                          % ����
clear all;                  %����ڴ��Ա�ӿ������ٶ�
close all;                  %�رյ�ǰ����figureͼ��
SamNum=20;                  %������������Ϊ20
TestSamNum=20;              %������������Ҳ��20
ForcastSamNum=2;            %Ԥ����������Ϊ2
HiddenUnitNum=8;            %�м�����ڵ�����ȡ8,�ȹ�����������1��
InDim=3;                    %��������ά��Ϊ3
OutDim=2;                   %�������ά��Ϊ2

%ԭʼ���� 
%����(��λ������)
sqrs=[20.55 22.44 25.37 27.13 29.45 30.10 30.96 34.06 36.42 38.09 39.13 39.99 ...
       41.93 44.59 47.30 52.89 55.73 56.76 59.17 60.63];
%��������(��λ������)
sqjdcs=[0.6 0.75 0.85 0.9 1.05 1.35 1.45 1.6 1.7 1.85 2.15 2.2 2.25 2.35 2.5 2.6...
        2.7 2.85 2.95 3.1];
%��·���(��λ����ƽ������)
sqglmj=[0.09 0.11 0.11 0.14 0.20 0.23 0.23 0.32 0.32 0.34 0.36 0.36 0.38 0.49 ... 
         0.56 0.59 0.59 0.67 0.69 0.79];
%��·������(��λ������)
glkyl=[5126 6217 7730 9145 10460 11387 12353 15750 18304 19836 21024 19490 20433 ...
        22598 25107 33442 36836 40548 42927 43462];
%��·������(��λ�����)
glhyl=[1237 1379 1385 1399 1663 1714 1834 4322 8132 8936 11099 11203 10524 11115 ...
        13320 16762 18673 20724 20803 21804];
p=[sqrs;sqjdcs;sqglmj];  %�������ݾ���
t=[glkyl;glhyl];           %Ŀ�����ݾ���
[SamIn,minp,maxp,tn,mint,maxt]=premnmx(p,t); %ԭʼ�����ԣ�������������ʼ��

rand('state',sum(100*clock))   %����ϵͳʱ�����Ӳ��������         
NoiseVar=0.01;                    %����ǿ��Ϊ0.01������������Ŀ����Ϊ�˷�ֹ���������ϣ�
Noise=NoiseVar*randn(2,SamNum);   %��������
SamOut=tn + Noise;                   %���������ӵ����������

TestSamIn=SamIn;                           %����ȡ�������������������ͬ��Ϊ��������ƫ��
TestSamOut=SamOut;                         %Ҳȡ������������������ͬ

MaxEpochs=50000;                              %���ѵ������Ϊ50000
lr=0.035;                                       %ѧϰ����Ϊ0.035
E0=0.65*10^(-3);                              %Ŀ�����Ϊ0.65*10^(-3)
W1=0.5*rand(HiddenUnitNum,InDim)-0.1;   %��ʼ���������������֮���Ȩֵ
B1=0.5*rand(HiddenUnitNum,1)-0.1;       %��ʼ���������������֮�����ֵ
W2=0.5*rand(OutDim,HiddenUnitNum)-0.1; %��ʼ���������������֮���Ȩֵ              
B2=0.5*rand(OutDim,1)-0.1;                %��ʼ���������������֮�����ֵ

ErrHistory=[];                              %���м����Ԥ��ռ���ڴ�
for i=1:MaxEpochs
    
    HiddenOut=logsig(W1*SamIn+repmat(B1,1,SamNum)); % �������������
    NetworkOut=W2*HiddenOut+repmat(B2,1,SamNum);    % ������������
    Error=SamOut-NetworkOut;                       % ʵ��������������֮��
    SSE=sumsqr(Error)                               %�������������ƽ���ͣ�

    ErrHistory=[ErrHistory SSE];

    if SSE<E0,break, end      %����ﵽ���Ҫ��������ѧϰѭ��
    
    % ����������BP��������ĵĳ���
    % ������Ȩֵ����ֵ�����������������ݶ��½�ԭ��������ÿһ����̬������
    Delta2=Error;
    Delta1=W2'*Delta2.*HiddenOut.*(1-HiddenOut);    

    dW2=Delta2*HiddenOut';
    dB2=Delta2*ones(SamNum,1);
    
    dW1=Delta1*SamIn';
    dB1=Delta1*ones(SamNum,1);
    %���������������֮���Ȩֵ����ֵ��������
    W2=W2+lr*dW2;
    B2=B2+lr*dB2;
    %���������������֮���Ȩֵ����ֵ��������
    W1=W1+lr*dW1;
    B1=B1+lr*dB1;
end

HiddenOut=logsig(W1*SamIn+repmat(B1,1,TestSamNum)); % ������������ս��
NetworkOut=W2*HiddenOut+repmat(B2,1,TestSamNum);    % �����������ս��
a=postmnmx(NetworkOut,mint,maxt);               % ��ԭ���������Ľ��
x=1990:2009;                                        % ʱ����̶�
newk=a(1,:);                                        % �������������
newh=a(2,:);                                        % �������������
figure ;
subplot(2,1,1);plot(x,newk,'r-o',x,glkyl,'b--+')    %��ֵ��·�������Ա�ͼ��
legend('�������������','ʵ�ʿ�����');
xlabel('���');ylabel('������/����');
subplot(2,1,2);plot(x,newh,'r-o',x,glhyl,'b--+')     %���ƹ�·�������Ա�ͼ��
legend('�������������','ʵ�ʻ�����');
xlabel('���');ylabel('������/���');

% ����ѵ���õ��������Ԥ��
% ����ѵ���õ������������pnew����Ԥ��ʱ��ҲӦ����Ӧ�Ĵ���
pnew=[73.39 75.55
      3.9635 4.0975
      0.9880 1.0268];                     %2010���2011���������ݣ�
pnewn=tramnmx(pnew,minp,maxp);         %����ԭʼ�������ݵĹ�һ�������������ݽ��й�һ����
HiddenOut=logsig(W1*pnewn+repmat(B1,1,ForcastSamNum)); % ���������Ԥ����
anewn=W2*HiddenOut+repmat(B2,1,ForcastSamNum);           % ��������Ԥ����

%������Ԥ��õ������ݻ�ԭΪԭʼ����������
anew=postmnmx(anewn,mint,maxt)         