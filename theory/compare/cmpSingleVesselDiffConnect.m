%% 研究单一缓冲罐不同接法对气流脉动的影响
function theoryDataCells = cmpSingleVesselDiffConnect(varargin)
    pp = varargin;
    massflowData = nan;
    param.meanFlowVelocity = nan;
    while length(pp)>=2
        prop =pp{1};
        val=pp{2};
        pp=pp(3:end);
        switch lower(prop)
            case 'massflowdata'
                massflowData = val;
            case 'meanflowvelocity'
                param.meanFlowVelocity = val;
        end
    end
    param.isOpening = 0;%管道闭口%rpm = 300;outDensity = 1.9167;multFre=[10,20,30];%环境25度绝热压缩到0.2MPaG的温度对应密度
    param.rpm = 420;
    param.outDensity = 1.5608;
    param.Fs = 4096;
    if isnan(massflowData)
        [massFlowRaw,time,~,param.meanFlowVelocity] = massFlowMaker(0.25,0.098,param.rpm...
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
        if isnan(param.meanFlowVelocity)
            param.meanFlowVelocity = 14;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    param.acousticVelocity = 345;%声速
    param.isDamping = 1;%是否计算阻尼
    param.coeffFriction = 0.003;%管道摩察系数

    param.mach = param.meanFlowVelocity / param.acousticVelocity;
    param.notMach = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    param.L1 = 3.5;%L1(m)
    param.L2 = 6;%L2（m）长度
    param.L3 = 1.5;%1.5;%双罐串联罐二作弯头两罐间距
    param.L4 = 4;%4%双罐串联罐二作弯头出口管长
    param.L5 = 5.85;%4.5;%双罐无间隔串联L2（m）长度
    param.Dpipe = 0.098;%管道直径（m）%应该是0.106
    param.l = 0.01;
    param.DV1 = 0.372;%缓冲罐的直径（m）
    param.LV1 = 1.1;%缓冲罐总长 （1.1m）
    param.DV2 = 0.372;%variant_DV2(i);%(4.*V2./(pi.*variant_r(i)))^(1/3);%缓冲罐的直径（0.372m）
    param.LV2 = 1.1;%variant_r(i).*param.DV2;%缓冲罐总长 （1.1m）
    param.V2 = pi.*param.DV2^2./4.*param.LV2;
    param.Lv1 = param.LV1./2;%缓冲罐腔1总长
    param.Lv2 = param.LV1-param.Lv1;%缓冲罐腔2总长   
    param.lv1 = param.LV1./2-(0.150+0.168);%param.Lv./2-0.232;%内插管长于偏置管，偏置管la=罐体总长-罐封头边缘到偏置管中心距
    param.lv2 = 0;%出口不偏置
    param.lv3 = 0.150+0.168;%针对单一偏置缓冲罐入口偏置长度
    param.Dbias = 0;%偏置管伸入罐体部分为0，所以对应直径为0
    param.sectionL1 = 0:0.25:param.L1;%[2.5,3.5];%0:0.25:param.L1;
    param.sectionL2 = 0:0.25:param.L2;
    param.sectionL3 = 0:0.25:param.L3;
    param.sectionL4 = 0:0.25:param.L4;
    param.sectionL5 = 0:0.25:param.L5;


    baseFrequency = 14;
    multFreTimes = 3;
    semiFreTimes = 3;
    allowDeviation = 0.5;
    beforeAfterMeaPoint = nan;
    calcPeakPeakValueSection = nan;

    dcpss = getDefaultCalcPulsSetStruct();
    dcpss.calcSection = [0.3,0.7];
    dcpss.sigma = 2.8;
    dcpss.fs = param.Fs;
    dcpss.isHp = 0;
    dcpss.f_pass = 7;%通过频率5Hz
    dcpss.f_stop = 5;%截止频率3Hz
    dcpss.rp = 0.1;%边带区衰减DB数设置
    dcpss.rs = 30;%截止区衰减DB数设置


    dataStructCells = {};
    calcDatas = {};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    count = 1;
    theoryDataCells{1,1} = '名称';
    theoryDataCells{1,2} = 'dataStrcutCell';
    theoryDataCells{1,3} = 'X';
    theoryDataCells{1,4} = 'param';
    count = count + 1;
    %%%%%%%%%%直管%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    straightPipeLength = param.L1 + 2*param.l + param.Lv1 + param.Lv2 + param.L2;
    straightPipeSection = [param.sectionL1,...
                            param.L1 + 2*param.l+param.Lv1+param.Lv2 + param.sectionL2];
    temp = find(straightPipeLength>param.L1);%找到缓冲罐所在的索引
    sepratorIndex = temp(1);

    pressure = straightPipePulsationCalc(param.massFlowE,param.fre,time...
            ,straightPipeLength,straightPipeSection...
            ,'d',param.Dpipe,'a',param.acousticVelocity,'isDamping',param.isDamping...
            ,'friction',param.coeffFriction,'meanFlowVelocity',param.meanFlowVelocity...
            ,'m',param.mach,'notMach',param.notMach,...
            'isOpening',param.isOpening);
    theoryDataCells{count,1} = sprintf('直管');
    theoryDataCells{count,2} = fun_dataProcessing(pressure...
                                ,'fs',param.Fs...
                                ,'basefrequency',baseFrequency...
                                ,'allowdeviation',allowDeviation...
                                ,'multfretimes',multFreTimes...
                                ,'semifretimes',semiFreTimes...
                                ,'beforeAfterMeaPoint',beforeAfterMeaPoint...
                                ,'calcpeakpeakvaluesection',nan...
                                );
    param.straightPipeLength = straightPipeLength;
    param.straightPipeSection = straightPipeSection;
    theoryDataCells{count,3} = straightPipeSection;
    theoryDataCells{count,4} = param;




    %  长度 L1     l    Lv   l    L2  
    %                   __________        
    %                  |          |      
    %       -----------|          |----------
    %                  |__________|       
    % 直径 Dpipe       Dv       Dpipe  
        %计算单一缓冲罐
    %%%%%%%%%%直进直出缓冲罐%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    count = count + 1;    
    [pressure1,pressure2] = oneVesselPulsationCalc(param.massFlowE,param.fre,time,...
            param.L1,param.L2,...
            param.LV1,param.l,param.Dpipe,param.DV1,...
            param.sectionL1,param.sectionL2,...
            'a',param.acousticVelocity,'isDamping',param.isDamping,'friction',param.coeffFriction,...
            'meanFlowVelocity',param.meanFlowVelocity,'isUseStaightPipe',1,...
            'm',param.mach,'notMach',param.notMach...
            ,'isOpening',param.isOpening...
        );
    rawDataStruct = fun_dataProcessing([pressure1,pressure2]...
        ,'fs',param.Fs...
        ,'basefrequency',baseFrequency...
        ,'allowdeviation',allowDeviation...
        ,'multfretimes',multFreTimes...
        ,'semifretimes',semiFreTimes...
        ,'beforeAfterMeaPoint',beforeAfterMeaPoint...
        ,'calcpeakpeakvaluesection',calcPeakPeakValueSection...
        );
    theoryDataCells{count,1} = '单一缓冲罐';
    theoryDataCells{count,2} = rawDataStruct;
    theoryDataCells{count,3} = [param.sectionL1,param.sectionL2+param.L1+2*param.l+param.LV1];
    theoryDataCells{count,4} = param;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Dbias 偏置管内插入缓冲罐的管径，如果偏置管没有内插如缓冲罐，Dbias为0
    %   Detailed explanation goes here
    %                       |  L2
    %              Lv    l  | outlet
    %        _______________|___ bias2
    %       |                   |  Dpipe
    %       |lv2  V          lv1|———— L1  
    %       |___________________| inlet
    %           Dv              l      
        
        %计算入口顺接出口前偏置
    %%%%%%%%%%直进侧前出缓冲罐%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    count = count + 1;
    [pressure1,pressure2] = ...
        vesselStraightFrontBiasPulsationCalc(param.massFlowE,param.fre,time,...
            param.L1,param.L2,...
            param.LV1,param.l,param.Dpipe,param.DV1,...
            param.lv3,param.Dbias,...
            param.sectionL1,param.sectionL2,...
            'a',param.acousticVelocity,'isDamping',param.isDamping,'friction',0.011,...
            'meanFlowVelocity',param.meanFlowVelocity,'isUseStaightPipe',1,...
            'm',param.mach,'notMach',param.notMach...
            ,'isOpening',param.isOpening...
            );%,'coeffDamping',opt.coeffDamping
    beforeAfterMeaPoint = [length(param.sectionL1),length(param.sectionL1)+1];
    pressure = [pressure1,pressure2];
    theoryDataCells{count,1} = sprintf('直进侧前出');
    theoryDataCells{count,2} = fun_dataProcessing(pressure...
                                ,'fs',param.Fs...
                                ,'basefrequency',baseFrequency...
                                ,'allowdeviation',allowDeviation...
                                ,'multfretimes',multFreTimes...
                                ,'semifretimes',semiFreTimes...
                                ,'beforeAfterMeaPoint',beforeAfterMeaPoint...
                                ,'calcpeakpeakvaluesection',nan...
                                );
    theoryDataCells{count,3} = [param.sectionL1,param.sectionL2+param.L1+param.l+param.lv3+param.DV1/2];
    theoryDataCells{count,4} = param;
    
end