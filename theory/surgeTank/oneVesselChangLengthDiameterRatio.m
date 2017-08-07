%% 单一缓冲罐迭代长径比研究
function theoryDataCells = oneVesselChangLengthDiameterRatio(varargin)
pp = varargin;
Dv = nan;
massflowData = nan;
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'massflowdata'
            massflowData = val;
        case 'dv'
            Dv = val;
	end
end
%% 初始参数
%
param.isOpening = 0;%管道闭口%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%环境25度绝热压缩到0.2MPaG的温度对应密度
param.rpm = 420;
param.outDensity = 1.5608;
param.Fs = 4096;

if isnan(massflowData)
    [massFlowRaw,time,~,opt.meanFlowVelocity] = massFlowMaker(0.25,0.098,param.rpm...
        ,0.14,1.075,param.outDensity,'rcv',0.15,'k',1.4,'pr',0.15,'fs',param.Fs,'oneSecond',6);
    [freRaw,AmpRaw,PhRaw,massFlowERaw] = frequencySpectrum(detrend(massFlowRaw,'constant'),param.Fs);
    freRaw = [7,14,21,28,14*3];
    massFlowERaw = [0.02,0.2,0.03,0.003,0.007];
    massFlowE = massFlowERaw;
    param.fre = freRaw;
    param.massFlowE = massFlowE;
else
    time = makeTime(param.Fs,1024);
    param.fre = massflowData(1,:);
    param.massFlowE = massflowData(2,:);
end

param.acousticVelocity = 345;%声速（m/s）
param.isDamping = 1;
param.coeffFriction = 0.03;
param.meanFlowVelocity = 16;
param.L1 = 3.5;%(m)
param.L2 = 6;
param.Lv = 1.1;
param.l = 0.01;%(m)缓冲罐的连接管长
param.Dv = 0.372;
param.sectionL1 = 0:0.5:param.L1;%linspace(0,param.L1,14);
param.sectionL2 = 0:0.5:param.L2;%linspace(0,param.L2,14);
param.Dpipe = 0.098;%管道直径（m）
param.X = [param.sectionL1, param.sectionL1(end) + 2*param.l + param.Lv + param.sectionL2];

baseFrequency = 14;
multFreTimes = 3;
semiFreTimes = 3;
allowDeviation = 0.5;

V = (pi * param.Dv.^2 / 4) .* param.Lv;%缓冲罐体积
%开始计算迭代的Lv和Dv
if isnan(Dv)
    Dv = 0.1:0.05:0.9;
end
Lv = (4*V) ./ (pi * Dv.^2);
dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.2,0.8];
dcpss.fs = param.Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%通过频率5Hz
dcpss.f_stop = 5;%截止频率3Hz
dcpss.rp = 0.1;%边带区衰减DB数设置
dcpss.rs = 30;%截止区衰减DB数设置
theoryDataCells{1,1} = '描述';
theoryDataCells{1,2} = 'dataCells';
theoryDataCells{1,3} = 'input';
theoryDataCells{1,4} = 'Lv';
theoryDataCells{1,5} = 'Dv';
theoryDataCells{1,6} = 'Lv/Dv(长径比)';
theoryDataCells{1,7} = 'X';

for i = 1:length(Dv)
    [pressure1,pressure2] = oneVesselPulsationCalc(param.massFlowE,param.fre,time...
        ,param.L1,param.L2,Lv(i),param.l,param.Dpipe,Dv(i) ...
        ,param.sectionL1,param.sectionL2 ...
        ,'a',param.acousticVelocity...
        ,'isDamping',param.isDamping...
        ,'friction',param.coeffFriction...
        ,'meanFlowVelocity',param.meanFlowVelocity...
        );
    beforeAfterMeaPoint = [length(param.sectionL1),length(param.sectionL1)+1];
    pressure = [pressure1,pressure2];
    %[plus,filterData] = calcPuls(pressure,dcpss);
    theoryDataCells{i+1,1} = sprintf('缓冲罐长:%g,直径:%g,长径比:%g',Lv(i),Dv(i),Lv(i)/Dv(i));
    theoryDataCells{i+1,2} = fun_dataProcessing(pressure...
                                ,'fs',param.Fs...
                                ,'basefrequency',baseFrequency...
                                ,'allowdeviation',allowDeviation...
                                ,'multfretimes',multFreTimes...
                                ,'semifretimes',semiFreTimes...
                                ,'beforeAfterMeaPoint',beforeAfterMeaPoint...
                                ,'calcpeakpeakvaluesection',nan...
                                );
    theoryDataCells{i+1,3} = param;
    theoryDataCells{i+1,4} = Lv(i);
    theoryDataCells{i+1,5} = Dv(i);
    theoryDataCells{i+1,6} = Lv(i)/Dv(i);
    theoryDataCells{i+1,7} = [param.sectionL1, param.sectionL1(end) + 2*param.l + Lv(i) + param.sectionL2];
end


end