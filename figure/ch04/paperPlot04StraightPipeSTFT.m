function d = paperPlot04StraightPipeSTFT(straightPipeDataCells,isSavePlot)
%����ֱ�ܵ�ʱƵ��������
%% ������������
%ʱƵ������������
	if nargin < 2
		isSavePlot = 0;
	end
	Fs = 100;%ʵ�������
	STFT.windowSectionPointNums = 512;
	STFT.noverlap = floor(STFT.windowSectionPointNums*3/4);
	STFT.nfft=2^nextpow2(STFT.windowSectionPointNums);
% 	STFTChartType = 'contour';%contour|plot3
	chartType = 'plot3';
	rang = 1:13;
% 	titleLabel = {'a','b','c','d','e','f','g','h','i','j','k','l','m'};
	baseFre = 14;
	baseFre1Amp = [];
	baseFre1Time = [];
	baseFre2Amp = [];
	baseFre2Time = [];
	count = 1;
	for i=rang
		figHandle = figure;
		paperFigureSet('small',6);
		pressure = straightPipeDataCells.pressure(:,i);
		hold on;
		[fh,sd,mag] = plotSTFT(pressure,STFT,Fs,'isShowColorbar',0,'chartType',chartType);
		%����1��Ƶ��2��Ƶ
		x1f = zeros(1,size(mag,2));
		y1f = sd.T;
		z1f = x1f;
		x2f = x1f;
		y2f = sd.T;
		z2f = x1f;
		for j = 1:size(mag,2)
			[z1f(j),x1f(j),index] = closeLargeValue(sd.F,mag(:,j),baseFre,0.5);
			[z2f(j),x2f(j),index] = closeLargeValue(sd.F,mag(:,j),baseFre*2,0.5);
        end
		%�궨1,2��Ƶ
		h = plot3(x1f,y1f,z1f,'-.b');
		h = plot3(x2f,y2f,z2f,'-.b');
		baseFre1Amp(count,:) = z1f;
		baseFre2Amp(count,:) = z2f;
		baseFre1Time = sd.T;
		baseFre2Time = baseFre1Time;
		title(sprintf('���%d',i),'FontName',paperFontName(),'FontSize',paperFontSize());
		xlabel('Ƶ��(Hz)','FontName',paperFontName(),'FontSize',paperFontSize()); 
		ylabel('ʱ��(s)','FontName',paperFontName(),'FontSize',paperFontSize());
		zlabel('��ֵ','FontName',paperFontName(),'FontSize',paperFontSize());
		axis tight;
		box on;
		view(25,53);
		d.sd{count} = sd;
		count = count + 1;
		if isSavePlot
			set(gca,'color','none');
			saveFigure(fullfile(getPlotOutputPath(),'ch04'),sprintf('ֱ��ʱƵ����-���%d',i));
			close(figHandle);
		end
        
	end
	d.baseFre1Amp = baseFre1Amp;
	d.baseFre2Amp = baseFre2Amp;
	%���Ʊ�Ƶ
	chartType = '2d';
	%��������1��Ƶ
	figHandle = figure;
	paperFigureSet('normal',6);
	if strcmpi(chartType,'2d')
		hold on;
        legendText = {};
		for i = 1:length(rang)
			h(i) = plot(baseFre1Time,baseFre1Amp(i,:),'color',getPlotColor(i),'marker',getMarkStyle(i));
            legendText{i} = sprintf('���%d',rang(i));
        end
        hl = legend(h,legendText,'FontSize',paperFontSize());
		box on;
		xlabel('ʱ��');
		ylabel('��ֵ');
	else
		hold on;
		for i = 1:length(rang)
			h = plotSpectrum3(baseFre1Time,baseFre1Amp(i,:),rang(i),'isFill',1,'color',[229,44,77]./255);
		end
		xlabel('ʱ��');
		ylabel('���');
		zlabel('��ֵ');
		axis tight;
		box on;
	end
	if isSavePlot
		set(gca,'color','none');
		saveFigure(fullfile(getPlotOutputPath(),'ch04'),sprintf('ֱ��ʱƵ����-���1��Ƶ'));
        close(figHandle);
	end
	%��������2��Ƶ
	figHandle = figure;
	paperFigureSet('normal',6);
	if strcmpi(chartType,'2d')
		hold on;
		for i = 1:size(baseFre2Amp,1)
			h = plot(baseFre2Time,baseFre2Amp(i,:),'color',getPlotColor(i),'marker',getMarkStyle(i));
		end
		box on;
		xlabel('ʱ��');
		ylabel('��ֵ');
	else
		hold on;
		for i = 1:length(rang)
			h = plotSpectrum3(baseFre2Time,baseFre2Amp(i,:),rang(i),'isFill',1,'color',[229,44,77]./255);
		end
		xlabel('ʱ��');
		ylabel('���');
		zlabel('��ֵ');
		axis tight;
		box on;
	end
	if isSavePlot
		set(gca,'color','none');
		saveFigure(fullfile(getPlotOutputPath(),'ch04'),sprintf('ֱ��ʱƵ����-���2��Ƶ'));
		close(figHandle);
	end
end