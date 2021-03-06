function paperPlotStraightInBiasOutExp(isSaveFigure)
    %绘制直进侧出缓冲罐实验结果
    %% 数据路径
    dataPath = getDataPath();
    vesselSideFontInDirectOutCombineDataPath = fullfile(dataPath,'实验原始数据\无内件缓冲罐\RPM420');%侧前进直后出
    vesselDirectInSideFontOutCombineDataPath = fullfile(dataPath,'实验原始数据\无内件缓冲罐\单罐直进侧前出420转0.05mpa');
    vesselDirectInSideBackOutCombineDataPath = fullfile(dataPath,'实验原始数据\无内件缓冲罐\单罐直进侧后出420转0.05mpa');
    vesselDirectInDirectOutCombineDataPath = fullfile(dataPath,'实验原始数据\无内件缓冲罐\单罐直进直出420转0.05mpaModify');
    vesselDirectPipeCombineDataPath = fullfile(dataPath,'实验原始数据\纯直管\RPM420-0.1Mpa\');
    %% 加载中间孔板以及缓冲罐数据
    [vesselSideFontInDirectOutDataCells,vesselSideFontInDirectOutCombineData] ...
        = loadExpDataFromFolder(vesselSideFontInDirectOutCombineDataPath);%侧前进直后出

    [vesselDirectInSideFontOutDataCells,vesselDirectInSideFontOutCombineData] ...
        = loadExpDataFromFolder(vesselDirectInSideFontOutCombineDataPath);%直进侧前出

    [vesselDirectInSideBackOutDataCells,vesselDirectInSideBackOutCombineData] ...
        = loadExpDataFromFolder(vesselDirectInSideBackOutCombineDataPath);%直进侧后出

    [vesselDirectInDirectOutDataCells,vesselDirectInDirectOutCombineData] ...
        = loadExpDataFromFolder(vesselDirectInDirectOutCombineDataPath);%直进直出

    [vesselDirectPipeDataCells,vesselDirectPipeCombineData] ...
        = loadExpDataFromFolder(vesselDirectPipeCombineDataPath);%纯直管

    combineDataStruct = vesselDirectPipeCombineData;
    combineDataStruct.readPlus(:,12) = combineDataStruct.readPlus(:,12)+2;
    vesselDirectPipeCombineData = combineDataStruct;

    plotStraightInBiasOutPressurePlus(...
        vesselDirectInSideFontOutCombineData...
        ,vesselDirectInSideBackOutCombineData...
        ,vesselDirectPipeCombineData...
        ,isSaveFigure);

    plotStraightInBiasOutSuppressionRate(...
        vesselDirectInSideFontOutCombineData...
        ,vesselDirectInSideBackOutCombineData...
        ,vesselDirectPipeCombineData...
        ,isSaveFigure);
end

function plotStraightInBiasOutPressurePlus(...
    DirectInSideFontOut...
    ,DirectInSideBackOut...
    ,DirectPipe...
    ,isSaveFigure)
    figure
    paperFigureSet('small',6);
    leg = {'直进侧前','直进侧后','直管'};
    fh = figureExpPressurePlus({DirectInSideFontOut,DirectInSideBackOut,DirectPipe},leg...
            ,'errorType','ci'...
            ,'markerStyle','point' ...
            ,'showPureVessel',0 ...
            ,'isFigure',0);
    fixSmallFigurePosition(fh);
%     set(gca,'Position',[0.149323668042243 0.179016148252809 0.784466286295657 0.658032462858302]);
    set(fh.legend,'Position',[0.158482650276879 0.577408943325708 0.376811589019886 0.240822313815662]);
    for i=1:length(fh.plotHandle)
        set(fh.plotHandle(i),'LineWidth',1.5,'Marker','none');
    end
%     set(fh.textarrowVessel,'X',[0.415496575342466 0.324885844748859],'Y',[0.523958333333334 0.466631944444445]);
    if isSaveFigure
        set(gca,'color','none');
        saveFigure(fullfile(getPlotOutputPath(),'ch05'),'直进侧前出-侧后出脉动对比');
    end
end

function plotStraightInBiasOutSuppressionRate(...
    DirectInSideFontOut...
    ,DirectInSideBackOut...
    ,DirectPipe...
    ,isSaveFigure)
    rangs = 1:13;
    figure
    paperFigureSet('small',6);
    [ddMean,stdVal,maxVal,minVal,muci] = getExpCombineReadedPlusData(DirectPipe);
    ddMean = ddMean(rangs);
    suppressionRateBase = {ddMean};
    suppressionRateBaseErr = muci(2,rangs) - muci(1,rangs);
    fh = figureExpPressurePlusSuppressionRate({DirectInSideFontOut,DirectInSideBackOut}...     
            ,{'直进侧前出','直进侧后出'}...
            ,'errorPlotType','bar'...
            ,'showVesselRigon',1 ...
            ,'suppressionRateBase',suppressionRateBase...
            ,'suppressionRateBaseErr',suppressionRateBaseErr...
            ,'xIsMeasurePoint',0 ...
            ,'figureHeight',6 ...
            ,'xlabelText','管线距离(m)'...
            ,'ylabelText','相对脉动抑制比(%)'...
            ,'isFigure',0 ...
            ,'rangs',rangs...
            ,'markerStyle','point'...
            );
    fixSmallFigurePosition(fh);
%     set(fh.plotHandle(1),'Marker','none','LineStyle','--');
%     set(fh.plotHandle(2),'Marker','none');
%     for i = 1:length(fh.measurePointGrid)
%         set(fh.measurePointGrid(i),'LineStyle',':');
%     end
    xlim([2,11]);
%     set(fh.gca,'Position',[0.183533105022831 0.188819444444445 0.735790563019412 0.630347222222228]);
    set(fh.legend,'Position',[0.468841354327746 0.6 0.420433783473354 0.167569440239006]);
    if isSaveFigure
        set(gca,'color','none');
        saveFigure(fullfile(getPlotOutputPath(),'ch05'),'直进侧前出-侧后出脉动抑制率对比');
    end
end