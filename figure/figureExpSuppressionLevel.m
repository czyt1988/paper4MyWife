function fh = figureExpSuppressionLevel(dataCombineStructCells,varargin)
%绘制实验数据的压力脉动和抑制率图,这里的脉动抑制率是读取时自动和无内件缓冲罐的脉动抑制率，如果要自己计算
%请使用figureExpPressurePlusSuppressionRate
%允许特殊的把地一个varargin作为legend
pp = varargin;
errorType = 'ci';%绘制误差带的模式，std：mean+-sd,ci为95%置信区间，minmax为最大最小
rang = 1:13;
expVesselRang = constExpVesselRangDistance();
%允许特殊的把地一个varargin作为legend
yFilterFunPtr = [];
legendLabels = {};
errorPlotType = 'bar';
isFigure = true;
showMeasurePoint = true;
showVesselRegion = true;
ylimValue = [];
if 0 ~= mod(length(pp),2)
    legendLabels = pp{1};
    pp=pp(2:end);
end

while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'errortype' %误差带的类型
        	errorType = val;
        case 'errorplottype'
            errorPlotType = val;
        case 'rang'
            rang = val;
        case 'yfilterfunptr'
            yFilterFunPtr = val;
        case 'expvesselrang'
            expVesselRang = val;
        case 'isfigure'
            isFigure = val;
        case 'showvesselregion'
            showVesselRegion = val;
        case 'showmeasurepoint'
            showMeasurePoint = val;
        case 'ylim'
            ylimValue = val;
        otherwise
       		error('参数错误%s',prop);
    end
end

if isFigure
    fh.figure = figure;
    paperFigureSet_normal();
end
x = constExpMeasurementPointDistance();%测点对应的距离

for plotCount = 1:length(dataCombineStructCells)
    yFunPtr = [];
    if 1 == length(dataCombineStructCells)
        [y,stdVal,maxVal,minVal,muci] = getExpCombineReadSuppressionLevelData(dataCombineStructCells);
        yFunPtr = yFilterFunPtr;
    else     
        [y,stdVal,maxVal,minVal,muci] = getExpCombineReadSuppressionLevelData(dataCombineStructCells{plotCount});
        if ~isempty(yFilterFunPtr)
            if 1 == length(yFilterFunPtr)
                yFunPtr = yFilterFunPtr;
            else
                yFunPtr = yFilterFunPtr{plotCount};
            end
        end
    end
    if isnan(y)
        error('此数据未有进行完全的分析，没有脉动抑制率');
    end
    y = y(rang).*100;

    if strcmp(errorType,'std')
        yUp = y + stdVal(rang).* 100;
        yDown = y - stdVal(rang).* 100;
    elseif strcmp(errorType,'ci')
        yUp = muci(2,rang).* 100;
        yDown = muci(1,rang).* 100;
    elseif strcmp(errorType,'minmax')
        yUp = maxVal(rang).* 100;
        yDown = minVal(rang).* 100;
    end
    
    if isa(yFunPtr,'function_handle')
        [y,yUp,yDown]= yFunPtr(y,yUp,yDown);
    end

    if strcmp(errorType,'none')
        fh.plotHandle(plotCount) = plot(x,y,'color',getPlotColor(plotCount)...
            ,'Marker',getMarkStyle(plotCount));
    else
        [fh.plotHandle(plotCount),fh.errFillHandle(plotCount)] = plotWithError(x,y,yUp,yDown,'color',getPlotColor(plotCount)...
            ,'Marker',getMarkStyle(plotCount)...
            ,'type',errorPlotType);
    end
end
xlim([2,11]);
if ~isempty(ylimValue)
    ylim(ylimValue);
end
if ~isempty(legendLabels)
    fh.legend = legend(fh.plotHandle,legendLabels,0);
end


if showVesselRegion
    fh.textarrowVessel = annotation('textarrow',[0.38 0.33],...
        [0.744 0.665],'String',{'抑制装置'},'FontName',paperFontName(),'FontSize',paperFontSize());
    fh.vesselFillHandle = plotVesselRegion(gca,expVesselRang);
end
ax = axis;
yLabel2Detal = (ax(4) - ax(3))/12;

if isFigure
	set(gca,'Position',[0.13 0.18 0.79 0.65]);
end

if showMeasurePoint 
    
    for i = 1:length(x)
        fh.measurementGridLine(i) = plot([x(i),x(i)],[ax(3),ax(4)],':','color',[160,160,160]./255);
        if 0 == mod(i,2)
            continue;
        end
        % 绘制测点线
        
        if x(i) < 10
            fh.measurementText(i) = text(x(i)-0.15,ax(4)+yLabel2Detal,sprintf('%d',i),'FontName',paperFontName(),'FontSize',paperFontSize());
        else
            fh.measurementText(i) = text(x(i)-0.3,ax(4)+yLabel2Detal,sprintf('%d',i),'FontName',paperFontName(),'FontSize',paperFontSize());           
        end
    end
    fh.textboxMeasurePoint = annotation('textbox',...
        [0.48 0.885 0.0998 0.0912],...
        'String','测点',...
        'FaceAlpha',0,...
        'EdgeColor','none','FontName',paperFontName(),'FontSize',paperFontSize());
end



xlabel('管线距离(m)','FontSize',paperFontSize());
ylabel('相对脉动抑制率(%)','FontSize',paperFontSize());
box on;
fh.gca = gca;
end
