clear all;
close all;
%单一缓冲罐理论迭
%% 缓冲罐计算的参数设置
vType = 'BiasFontInStraightOut';
isSaveFigure = 0;
useMainPaper = 1;%大论文用
coeffFriction = 0.03;
if 0
    param.isOpening = 0;%管道闭口%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%环境25度绝热压缩到0.2MPaG的温度对应密??
    param.rpm = 420;
    param.outDensity = 1.5608;
    param.Fs = 4096;
    param.acousticVelocity = 335;%声速（m/s）
    param.isDamping = 1;
    param.L1 = 3.5;%(m)
    param.L2 = 6;
    param.L = 10;
    param.Lv = 1.1;
    param.l = 0.01;%(m)缓冲罐的连接管长
    param.Dv = 0.372;
    param.sectionL1 = 0:0.5:param.L1;%linspace(0,param.L1,14);
    param.sectionL2 = 0:0.5:param.L2;%linspace(0,param.L2,14);
    param.Dpipe = 0.098;%管道直径（m
    param.X = [param.sectionL1, param.sectionL1(end) + 2*param.l + param.Lv + param.sectionL2];
    param.lv1 = 0.318;
    param.lv2 = 0.318;
    coeffFriction = 0.02;
    meanFlowVelocity = 12;
    param.coeffFriction = coeffFriction;
    param.meanFlowVelocity = meanFlowVelocity;
    freRaw = [14,21,28,42,56,70];
    massFlowERaw = [0.23,0.00976,0.00515,0.00518,0.003351,0.00278];
else
    
    param.isOpening = 0;%管道闭口%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%环境25度绝热压缩到0.2MPaG的温度对应密??
    param.rpm = 420;
    param.outDensity = 1.5608;
    param.Fs = 4096;
    param.isDamping = 1;
    param.L1 = 3.5;%(m)
    param.L2 = 6;
    param.L = 10;
    param.Lv = 1.1;
    param.l = 0.01;%(m)缓冲罐的连接管长
    param.Dv = 0.372;
    param.sectionL1 = 0:0.5:param.L1;%linspace(0,param.L1,14);
    param.sectionL2 = 0:0.5:param.L2;%linspace(0,param.L2,14);
    param.Dpipe = 0.098;%管道直径（m
    param.X = [param.sectionL1, param.sectionL1(end) + 2*param.l + param.Lv + param.sectionL2];
    param.lv1 = 0.318;
    param.lv2 = 0.318;

    if useMainPaper %大论文用
        param.acousticVelocity = 320;
        param.coeffFriction = 0.03;
        param.meanFlowVelocity = 13;
    else
        param.acousticVelocity = 345;
        param.coeffFriction = 0.03;
        param.meanFlowVelocity = 13;
    end

    
    freRaw = [14,21,28,42,56,70];
    massFlowERaw = [0.23,0.00976,0.00515,0.00518,0.003351,0.00278];

end
massFlowData = [freRaw;massFlowERaw];

% [massFlowRaw,time,~,param.meanFlowVelocity] = massFlowMaker(0.25,0.098,param.rpm...
            % ,0.14,1.075,param.outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',param.Fs,'oneSecond',6);
% [freRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw,'constant'),param.Fs);

% massFlowERaw(freRaw>100)=[];
% freRaw(freRaw>100)=[];
% massFlowData = [freRaw';massFlowERaw];

%% 1迭代长径比
if 0
    paperPlotSingleVesselTheIteChangLengthDiameterRatio(param,massFlowData,isSaveFigure);
end

%% 迭代缓冲罐位置
if 0
    paperPlotSingleVesselTheIteChangL1(param,massFlowData,isSaveFigure);
end

%% 迭代偏置距离和长径比
if 0
	paperPlotSingleVesselTheIteBiasLengthAndAspectRatio(param,massFlowData,isSaveFigure);
end

%% 迭代缓冲罐lv1的偏置入口管长
if 1
    paperPlotSingleVesselTheIteChangLv1(param,massFlowData,isSaveFigure);
end

%% 迭代相同长径比下，不同体积不同偏置距离的影响
if 0
    paperPlotSingleVesselTheIteChangeVAndBiasLengthFixAR(param,massFlowData,isSaveFigure);
end


if 0
    vType = 'StraightInBiasOut';%biasInBiasOut,EqualBiasInOut,BiasFontInStraightOut,straightinbiasout,BiasFrontInBiasFrontOut,
	paperPlotSingleVesselTheoryFrequencyResponse(param,vType,isSaveFigure);
end