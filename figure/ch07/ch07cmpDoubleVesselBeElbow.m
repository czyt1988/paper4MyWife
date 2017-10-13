%% 第七章 绘图 - 双罐弯头式缓冲罐理论分析对比
%第七章画图的参数设置
clear all;
close all;
clc;
baseField = 'rawData';
errorType = 'ci';
dataPath = getDataPath();
%% 加载实验和模拟数据
expStraightLinkCombineDataPath = fullfile(dataPath,'实验原始数据\双缓冲罐研究\双缓冲罐串联420转0.1mpa');
expElbowLinkCombineDataPath = fullfile(dataPath,'实验原始数据\双缓冲罐研究\双缓冲罐串联罐二当弯头420转0.1mpa');
%加载实验数据 及 模拟数据
[expStraightLinkDataCells,expStraightLinkCombineData,simStraightLinkDataCells] ...
    = loadExpAndSimDataFromFolder(expStraightLinkCombineDataPath);
[expElbowLinkDataCells,expElbowLinkCombineData,simElbowLinkDataCells] ...
    = loadExpAndSimDataFromFolder(expElbowLinkCombineDataPath);
legendText = {'双缓冲罐串联','双缓冲罐弯头串联'};
%% 加载理论数据
% 理论对比分析-对比{'直管';'单一缓冲罐';'直进侧前出';'双罐-罐二作弯头';'双罐无间隔串联'}
freRaw = [7,14,21,28,14*3];
massFlowERaw = [0.02,0.2,0.03,0.003,0.007];
% theoryDataCells = cmpDoubleVesselBeElbow('massflowdata',[freRaw;massFlowERaw]...
%     ,'meanFlowVelocity',14);
theoryDataCells = cmpDoubleVesselBeElbow();
theAnalysisRow = [6,5];

legendLabels = theoryDataCells(theAnalysisRow,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  下面开始绘图
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 绘制-模拟-实验-理论 对比分析
%模拟对应距离
% xSim{1} = [[0.5,1,1.5,2,2.5,2.85,3]-0.25  ,[4.2] ,[5.5,6.5,7,7.5,8,8.5,9,9.5,10]] + 0.5;
% xSim{2} = [[0.5,1,1.5,2,2.5,2.85,3]-0.25  ,[4.5,5,5.5],  [6.5,7,7.5,8,8.5,9,9.5,10]] + 0.5;
xSim{1} = [[0.5,1,1.5,2,2.5]+0.5 ,[6.5,7,7.5,8,8.5,9,9.5,10]] ;
xSim{2} = [[0.5,1,1.5,2,2.5,2.85]  ,[4.5,5,5.5]+0.65,  [7,7.5,8,8.5,9,9.5,10]+1.05];
%实验对应距离
xStraightLinkVessel = [2.5,3,6.25,7.05,7.55,8.05,8.55,9.05,9.55,10.05];%缓冲罐串联的距离
xElbowLinkVessel = [2.5,3,5.15,5.65,6.15,8.05,8.55,9.05,9.55,10.05,10.55,11.05];%缓冲罐弯头式缓冲罐距离
xExp = {xStraightLinkVessel,xElbowLinkVessel};
%实验对应测点
expRangStraightLinkVessel = [1,2,4,7,8,9,10,11,12,13];
expRangElbowLinkVessel = [1,2,4,5,6,7,8,9,10,11,12,13];
expRang = {expRangStraightLinkVessel,expRangElbowLinkVessel};
if 1
%理论数据
thePlusValue = theoryDataCells(theAnalysisRow,2);%通过此函数的行索引设置不同的对比值
xThe = theoryDataCells(theAnalysisRow,3);
%两个情况缓冲罐对应距离
vesselRegion1 = [3.8,6];
vesselRegion2_1 = [3.8,4.9];
vesselRegion2_2 = [6.4,7.5];
%模拟测点
simRang{1} = [1:5,10:17];
simRang{2} = [1:6,8:10,12:18];
fh = figureExpAndSimThePressurePlus({expStraightLinkCombineData,expElbowLinkCombineData}...
                        ,{simStraightLinkDataCells,simElbowLinkDataCells}...
                        ,thePlusValue...
                        ,legendText...
                        ,'showMeasurePoint',0 ...
                        ,'xsim',xSim,'xexp',xExp,'xThe',xThe...
                        ,'expRang',expRang,'simRang',simRang...
                        ,'showVesselRigion',0,'ylim',[0,40]...
                        ,'xlim',[2,12]);
set(fh.legend,...
    'Position',[0.510792832222114 0.633897577329641 0.396874991851965 0.346163184982207]);
plotVesselRegion(fh.gca,vesselRegion1,'color',getPlotColor(1),'yPercent',[0,0]...
    ,'FaceAlpha',0.3,'EdgeAlpha',0.3);
plotVesselRegion(fh.gca,vesselRegion2_1,'color',getPlotColor(2),'yPercent',[0,0]...
    ,'FaceAlpha',0,'EdgeAlpha',1);
plotVesselRegion(fh.gca,vesselRegion2_2,'color',getPlotColor(2),'yPercent',[0,0]...
    ,'FaceAlpha',0,'EdgeAlpha',1);
annotation(fh.figure,'textarrow',[0.336545138888889 0.391666666666667],...
    [0.776614583333333 0.727005208333333],'String',{'A'});
annotation(fh.figure,'textarrow',[0.23953125 0.268194444444445],...
    [0.654244791666667 0.594713541666667],'String',{'B'});
annotation(fh.figure,'textarrow',[0.415920138888889 0.468836805555556],...
    [0.6509375 0.594713541666667],'String',{'C'});

end
%% 绘制倍频特性
if 0
    fh = figureExpNatureFrequency({expStraightLinkCombineData,expElbowLinkCombineData}...
        ,{'双罐串联','弯头式缓冲罐'}...
        ,'xs',xExp...
        ,'rang',expRang...
        ,'showVesselRigon',0);
    plotVesselRegion(fh.gca,vesselRegion1,'color',getPlotColor(1),'yPercent',[0,0]...
        ,'FaceAlpha',0.3,'EdgeAlpha',0.3);
    plotVesselRegion(fh.gca,vesselRegion2_1,'color',getPlotColor(2),'yPercent',[0,0]...
        ,'FaceAlpha',0,'EdgeAlpha',1);
    plotVesselRegion(fh.gca,vesselRegion2_2,'color',getPlotColor(2),'yPercent',[0,0]...
        ,'FaceAlpha',0,'EdgeAlpha',1);
    annotation(fh.figure,'textarrow',[0.345364583333333 0.409305555555556],...
        [0.786536458333334 0.75015625],'String',{'A'});
    annotation(fh.figure,'textarrow',[0.248350694444445 0.283628472222222],...
        [0.664166666666667 0.59140625],'String',{'B'});
    annotation(fh.figure,'textarrow',[0.471041666666667 0.512934027777778],...
        [0.667473958333333 0.598020833333333],'String',{'C'});
end
%% 绘制详细倍频特性
if 0
    fh = figureExpNatureFrequencyBar({expElbowLinkCombineData,expStraightLinkCombineData}...
    ,1 ...
    ,{'弯头式缓冲罐','双罐串联'}...
    );
    fh = figureExpNatureFrequencyBar({expElbowLinkCombineData,expStraightLinkCombineData}...
    ,2 ...
    ,{'弯头式缓冲罐','双罐串联'}...
    );
end