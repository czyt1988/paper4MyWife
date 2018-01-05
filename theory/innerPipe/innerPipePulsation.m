%% 内插管的气流脉动
function theoryDataCells = innerPipePulsation(varargin)
pp = varargin;

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
param.Lv = 1.1;
param.l = 0.01;%(m)缓冲罐的连接管长
param.Dv = 0.372;
param.sectionL1 = 0:0.5:param.L1;%linspace(0,param.L1,14);
param.sectionL2 = 0:0.5:param.L2;%linspace(0,param.L2,14);
param.Dpipe = 0.098;%管道直径（m）
param.X = [param.sectionL1, param.sectionL1(end) + 2*param.l + param.Lv + param.sectionL2];
param.lv1 = 0.318;
param.lv2 = 0.318;
baseFrequency = 14;
multFreTimes = 3;
semiFreTimes = 3;
massflowData = nan;
param.Lin = 200;
param.Lout = 200;
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'massflowdata'
            massflowData = val;
        case 'param'
            param = val;
		case 'basefrequency'
			baseFrequency = val;
		case 'multfretimes'
			multFreTimes = val;
		case 'semifretimes'
			semiFreTimes = val;	
        otherwise
            error('错误属性%s',prop);
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
theoryDataCells{1,3} = 'X';
theoryDataCells{1,4} = '脉动值';
theoryDataCells{1,5} = 'input';

vhpicStruct.Lin = param.Lin;
vhpicStruct.Lin = param.Lin;
[pressure1,pressure2] = innerPipeVesselInBiasPulsationCalc(param.massFlowE,param.fre,time...
	,param.L1,param.L2,param.Dpipe,param.Dv...
	,d,param.bias,param.sectionL1,param.sectionL2...
	,'a',param.acousticVelocity...
	,'isDamping',param.isDamping...
	,'friction',param.coeffFriction...
	,'meanFlowVelocity',param.meanFlowVelocity...
	,'isOpening',isOpening...
);

beforeAfterMeaPoint = [length(param.sectionL1),length(param.sectionL1)+1];
pressure = [pressure1,pressure2];
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
theoryDataCells{i+1,3} = [param.sectionL1, param.sectionL1(end) + 2*param.l + param.Lv1 + param.Lv2 + param.sectionL2];
theoryDataCells{i+1,4} = d;
theoryDataCells{i+1,5} = param;



end
