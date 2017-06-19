function [ output_args ] = plotExpSuppressionLevel(dataCombineStruct,varargin)
%����ʵ�����ݵ�ѹ��������������ͼ
pp = varargin;
errorType = 'std';
rang = 1:13;
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'errortype' %����������
        	errorType = val;
        case 'rang'
            rang = val;
        otherwise
       		error('��������%s',prop);
    end
end
[y,stdVal,maxVal,minVal] = getExpCombineReadSuppressionLevelData(dataCombineStruct);
if isnan(y)
    error('������δ�н�����ȫ�ķ�����û������������');
end
figure
paperFigureSet_normal();
x = constExpMeasurementPointDistance();%����Ӧ�ľ���
y = y(rang)*100;

if strcmp(errorType,'std')
    yUp = y + stdVal(rang);
    yDown = y - stdVal(rang);
else
    yUp = maxVal(rang);
    yDown = minVal(rang);
end
[curHancle,fillHandle] = plotWithError(x,y,yUp,yDown,'color',getPlotColor(1));
xlim([2,11]);

set(gca,'Position',[0.13 0.18 0.79 0.65]);
annotation('textbox',...
    [0.48 0.885 0.0998 0.0912],...
    'String','���',...
    'FaceAlpha',0,...
    'EdgeColor','none','FontName',paperFontName(),'FontSize',paperFontSize());
annotation('textarrow',[0.38 0.33],...
    [0.744 0.665],'String',{'�����'},'FontName',paperFontName(),'FontSize',paperFontSize());
plotVesselRegion(gca,constExpVesselRangDistance());
ax = axis;
% ���Ʋ����
for i = 1:length(x)
    plot([x(i),x(i)],[ax(3),ax(4)],':','color',[160,160,160]./255);
    if 0 == mod(i,2)
        continue;
    end
    if x(i) < 10
        text(x(i)-0.15,ax(4)+5,sprintf('%d',i),'FontName',paperFontName(),'FontSize',paperFontSize());
    else
        text(x(i)-0.3,ax(4)+5,sprintf('%d',i),'FontName',paperFontName(),'FontSize',paperFontSize());           
    end
end
xlabel('���߾���');
ylabel('����������(%)');
--
end

function yData = fixY(y)

end