%% 内置孔板缓冲罐变孔板孔径
function theoryDataCells = innerOrificTankChangD(varargin)
pp = varargin;
massflowData = nan;
isOpening = 0;
orificD = [0.25,0.5,0.75,1];



%% 初始参数
%
param.isOpening = 0;%管道闭口%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%环境25度绝热压缩到0.2MPaG的温度对应密度
param.rpm = 420;
param.outDensity = 1.5608;
param.Fs = 4096;
param.acousticVelocity = 345;%声速（m/s）
param.isDamping = 1;
param.coeffFriction = 0.03;
param.meanFlowVelocity = 16;
param.L1 = 3.5;%(m)
param.L2 = 6;
param.Lv1 = 1.1/2;
param.Lv2 = 1.1/2;
param.l = 0.01;%(m)缓冲罐的连接管长
param.Dv = 0.372;
param.sectionL1 = 0:0.5:param.L1;%linspace(0,param.L1,14);
param.sectionL2 = 0:0.5:param.L2;%linspace(0,param.L2,14);
param.Dpipe = 0.098;%管道直径（m）
param.LBias = 0.168+0.150;
param.X = [param.sectionL1, param.sectionL1(end) + 2*param.l + param.Lv1 + param.Lv2 + param.sectionL2];

calcR = false;%是否计算脉动抑制率
isFast = false;

while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'massflowdata'
            massflowData = val;
        case 'orificd'
            orificD = val;
        case 'param'
            param = val;
		case 'calcr'
			calcR = val;
		case 'fast'
			isFast = val;
        case 'isopening'
            isOpening = val;
    end
end


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



baseFrequency = 14;
multFreTimes = 3;
semiFreTimes = 3;
allowDeviation = 0.5;


dcpss = getDefaultCalcPulsSetStruct();
dcpss.calcSection = [0.2,0.8];
dcpss.fs = param.Fs;
dcpss.isHp = 0;
dcpss.f_pass = 7;%通过频率5Hz
dcpss.f_stop = 5;%截止频率3Hz
dcpss.rp = 0.1;%边带区衰减DB数设置
dcpss.rs = 30;%截止区衰减DB数设置

if ~isFast
	theoryDataCells{1,1} = '描述';
	theoryDataCells{1,2} = 'dataCells';
	theoryDataCells{1,3} = 'X';
	theoryDataCells{1,4} = '内置孔板直径';
	theoryDataCells{1,5} = 'input';
end
%含孔板缓冲罐的气流脉动计算
%   Detailed explanation goes here
%           |  L1
%        l  | 
%   bias ___|_______________
%       |         |        |     L2
%   Dv  |          d        |----------- Dv1
%       |_________|________|      DPipe
%             LV1      LV2       

for i = 1:length(orificD)
    d = orificD(i);
    [pressure1,pressure2] = vesselBiasHaveOrificePulsationCalc(param.massFlowE,param.fre,time...
        ,param.L1,param.L2,param.Lv1,param.Lv2,param.l,param.Dpipe,param.Dv...
        ,d,param.LBias,param.sectionL1,param.sectionL2...
        ,'a',param.acousticVelocity...
        ,'isDamping',param.isDamping...
        ,'friction',param.coeffFriction...
        ,'meanFlowVelocity',param.meanFlowVelocity...
        ,'isOpening',isOpening...
    );
	X = [param.sectionL1, param.sectionL1(end) + 2*param.l + param.Lv1 + param.Lv2 + param.sectionL2];
    beforeAfterMeaPoint = [length(param.sectionL1),length(param.sectionL1)+1];
    pressure = [pressure1,pressure2];
	if calcR
		
	end
	if isFast
		theoryDataCells.puls = calcPuls(pressure,dcpss);
		theoryDataCells.X = X;
		theoryDataCells.d = d;
		theoryDataCells.param = param;
	else
		%[plus,filterData] = calcPuls(pressure,dcpss);
		theoryDataCells{i+1,1} = sprintf('内置孔板直径:%g',d);
		theoryDataCells{i+1,2} = fun_dataProcessing(pressure...
									,'fs',param.Fs...
									,'basefrequency',baseFrequency...
									,'allowdeviation',allowDeviation...
									,'multfretimes',multFreTimes...
									,'semifretimes',semiFreTimes...
									,'beforeAfterMeaPoint',beforeAfterMeaPoint...
									,'calcpeakpeakvaluesection',nan...
									);
		theoryDataCells{i+1,3} = X;
		theoryDataCells{i+1,4} = d;
		theoryDataCells{i+1,5} = param;
    end
end


end
