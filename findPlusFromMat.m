%% 手动定义脉动峰峰值
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%%
[fileName,pathName] = uigetfile('*.mat','选择实验数据预处理文件');
dataPath = getDataPath();
expMatDataPath = fullfile(pathName,fileName);
%expMatDataPath = fullfile(dataPath,'实验原始数据\缓冲罐内置孔板0.5D罐中间\开机300转带压.mat');
zoomIndexStartPresent = 0.3;%放大的开始位置0.3
zoomIndexEndPresent = 0.35;%放大的结束位置0.35
sigmaValues = [];
sigmaValuesCell = {};
plusValuesCell = {};
%%开始读取第一个数据的压力值
dataStructCells = load(expMatDataPath);
dataStructCells = dataStructCells.dataStructCells;
reject = 0;
quitProgram = 0;
isSave = 1;
sigmaData = 1.5;
plusValueMat = [];
sigmaValuesMat = [];
excelCells = {};
endDotIndex = strfind(fileName,'.');
excelPath = fileName(1:(endDotIndex(end)-1));
excelPath = strcat(excelPath,'_sigmaPlusValue.xls');
excelPath = fullfile(pathName,excelPath);
rpm = getRpmFromDataStruct(dataStructCells{1,2});
vesselCombineDataStruct = getPureVesselCombineDataStruct(rpm);%获取单一缓冲罐的数据
[ meanPureVesselVal,stdPureVesselVal,maxPureVesselVal,minPureVesselVal,muciPureVessel,sigmaciPureVessel ] = getExpCombineReadedPlusData(vesselCombineDataStruct);
if exist(excelPath,'file')
    [~,~,excelCells] = xlsread(excelPath);
end
excelStartRow = size(excelCells,1) + 1;
excelCells{excelStartRow,1} = datestr(now);
totalPointX = [];
totalPointY = [];
totalPointCount = 1;
for dataIndex = 1 : size(dataStructCells,1)
	dataStruct = dataStructCells{dataIndex,2};
	for i = 1:size(dataStruct.rawData.pressure,2)
    	p = dataStruct.rawData.pressure(:,i);
    	fs = dataStruct.input.fs;

		while 1
			if length(sigmaValues) > i
				sigmaData = sigmaValues(i);
            end
            if isempty(sigmaData)
                sigmaData = 1.5;
            end
	        sigmaData=inputdlg(sprintf('输入测点%d的sigma值',i),'sigma',1,{sprintf('%g',sigmaData)});
	        if isempty(sigmaData)
	        	strBtn1 = '终止计算退出程序';
	        	strBtn2 = '终止计算跳转下一个实验数据';
	        	strBtn3 = '跳到下一个测点';
	            button = questdlg('是否终止计算，或者跳到下一个测点'...
	                ,'询问'...
	                ,strBtn1,strBtn2,strBtn3,strBtn3);

	            if strcmp(button,strBtn1)
	            	quitProgram = 1;
	                warning('用户终止程序');
	                break;
	            elseif strcmp(button,strBtn2)
	                reject = 1;
	                break;
	            elseif strcmp(button,strBtn3)
	                reject = 0;
	                break;   
	            end
            end
            if quitProgram
                break;
            end

	        sigmaData = str2num(sigmaData{1});
	        [out_index,meadUpStd,meadDownStd,meanValue(i),stdValue] =  sigmaOutlierDetection(p,sigmaData);

	        fh = figure();
	        subplot(2,2,[1 2])
	        set(fh,'outerposition',get(0,'screensize'));
	        [~,time] = plotWave(p,fs);
	        hold on;
	        ax = axis();
	        h = plot([ax(1),ax(2)],[meadUpStd,meadUpStd],'--');
	        set(h,'color','r');
	        h = plot([ax(1),ax(2)],[meadDownStd,meadDownStd],'--');
	        set(h,'color','r');
	        title(sprintf('测点%d，总共有%d个点,sigma%g范围之外的有%d个点',i,length(p),sigmaData,length(out_index)));
	        subplot(2,2,3)
	        xStartIndex = ceil(length(time)*zoomIndexStartPresent);
	        xEndIndex = floor(length(time)*zoomIndexEndPresent);
	        plot(time(xStartIndex:xEndIndex),p(xStartIndex:xEndIndex),'-b');
            hold on;
	        ax = axis();
	        h = plot([ax(1),ax(2)],[meadUpStd,meadUpStd],'--');
	        set(h,'color','r');
	        h = plot([ax(1),ax(2)],[meadDownStd,meadDownStd],'--');
	        set(h,'color','r');
	        subplot(2,2,4)
            scatter(totalPointX,totalPointY,3);
            hold on;
            tmpY = meadUpStd - meadDownStd;
            scatter(i,tmpY,10,'r');
            plot(maxPureVesselVal);
            plot(minPureVesselVal);
            xlim([1 14]);
            box on;
	        button = questdlg(sprintf('是否可以作为测点%d的sigma值',i)...
	                ,'询问'...
	                ,'是','否','是');
	        if strcmp(button,'是')
	            close(fh);
                if i < 14
                    totalPointX(totalPointCount) = i;
                    totalPointY(totalPointCount) = meadUpStd - meadDownStd;
                    totalPointCount = totalPointCount+1;
                end
	            sigmaValues(1,i) = sigmaData;
	            plusValue(1,i) = meadUpStd - meadDownStd;
                excelCells{excelStartRow,i+1} = plusValue(1,i);
                excelCells{excelStartRow,i+21} = sigmaValues(1,i);
                
	            break;
	        else 
	            close(fh);
	            continue;
	        end
        end
        
        if quitProgram
        	break;
        end
	    if reject
	        break;
	    else
	    	continue;
        end



	end
    
	if quitProgram
		break;
	end
	if reject
	   reject = 0;
	   continue;
    end
    excelStartRow = excelStartRow + 1;
    dataStructCells{dataIndex,3} = plusValue;
    dataStructCells{dataIndex,4} = sigmaValues;
    plusValueMat(dataIndex,:) = plusValue;
    sigmaValuesMat(dataIndex,:) = sigmaValues;
end


if quitProgram
    button = questdlg('中途终止计算，是否需要保存啊亲~~'...
        ,'询问'...
        ,'保存','不要保存','不要保存');
    if strcmp(button,'保存')
        isSave = 1;
    else
        isSave = 0;
    end
end

if isSave
    save(expMatDataPath,'dataStructCells');
    dataStructCellMatFilePath = expMatDataPath;
    expMatDataPath = fileparts(dataStructCellMatFilePath);
    expMatDataPath = fullfile(expMatDataPath,'sigmaPlusValue.mat');
    st.expPlusValues = plusValueMat;
    st.expSigmaValues = sigmaValuesMat;
    save(expMatDataPath,'st');
    
    pathstr = fileparts(dataStructCellMatFilePath);
    %处理联合数据
    combineDataStruct = combineExprimentMatFile(dataStructCellMatFilePath);
    vesselCombineDataStruct = getPureVesselCombineDataStruct(rpm);
    combineDataStruct = calcSuppressionLevel(combineDataStruct,vesselCombineDataStruct,'rawData');
    combineDataStruct = calcSuppressionLevel(combineDataStruct,vesselCombineDataStruct,'subSpectrumData');
    combineDataStruct = calcSuppressionLevel(combineDataStruct,vesselCombineDataStruct,'saMainFreFilterStruct');
    combineDataStruct.descripe = {'readPlus是人为读取的压力脉动数据';'readSuppressionLevel是人为读取数据和单一缓冲罐进行的脉动抑制率计算'...
        ;'带SL结尾的是和单一缓冲罐进行对比的抑制率如multFreMag1SL'};
    saveCombineMatPath = fullfile(pathstr,'combineDataStruct.mat');
    save(saveCombineMatPath,'combineDataStruct');
%     xlswrite(excelPath,excelCells);
end