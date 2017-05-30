function combineDataStruct = combineExprimentMatFile(matFilePath)
%% �����Ѿ�������Ԥ������ʵ������mat�ļ����Զ������ݽ�������
% 
    load(matFilePath,'dataStructCells');
    %��ʼ����
    combineData = dealWithField(dataStructCells,'rawData');
    if isstruct(combineData)
        combineDataStruct.rawData = combineData;
    end
    combineData = dealWithField(dataStructCells,'subSpectrumData');
    if isstruct(combineData)
        combineDataStruct.subSpectrumData = combineData;
    end
    combineData = dealWithField(dataStructCells,'saMainFreFilterStruct');
    if isstruct(combineData)
        combineDataStruct.saMainFreFilterStruct = combineData;
    end
end

function combineData = dealWithField(dataStructCells,fieldName)
    for i = 1:size(dataStructCells,1)
        ds = dataStructCells{i,2};
        if ~isfield(ds,fieldName)
            return
        end
        datas = getfield(ds,fieldName);
        %rawData
        %multFreMag
        for row = 1:size(datas.multFreMag,1)
            eval(sprintf('combineData.multFreMag%d(i,:) = datas.multFreMag(%d,:);',row,row));
        end
        %semiFreMag
        for row = 1:size(datas.semiFreMag,1)
            eval(sprintf('combineData.semiFreMag%d(i,:) = datas.semiFreMag(%d,:);',row,row));
        end
        %statisPara - mean
        combineData.pressureMean(i,:) = datas.statisPara(1,:);
        %statisPara - mean
        combineData.pressureMedian(i,:) = datas.statisPara(2,:);
        %statisPara - max
        combineData.pressureMax(i,:) = datas.statisPara(3,:);
        %statisPara - min
        combineData.pressureMin(i,:) = datas.statisPara(4,:);
        %statisPara - mode ����
        combineData.pressureMode(i,:) = datas.statisPara(5,:);
        %statisPara - std ��׼��
        combineData.pressureStd(i,:) = datas.statisPara(6,:);
        %statisPara - var ����
        combineData.pressureVar(i,:) = datas.statisPara(7,:);
        %statisPara - Skewness ƫ��
        combineData.pressureSkewness(i,:) = datas.statisPara(8,:);
        %statisPara - kurtosis �Ͷ�
        combineData.pressureKurtosis(i,:) = datas.statisPara(9,:);

        %statisPara - mean
        combineData.pressureMean25(i,:) = datas.statisPara25(1,:);
        %statisPara - mean
        combineData.pressureMedian25(i,:) = datas.statisPara25(2,:);
        %statisPara - max
        combineData.pressureMax25(i,:) = datas.statisPara25(3,:);
        %statisPara - min
        combineData.pressureMin25(i,:) = datas.statisPara25(4,:);
        %statisPara - mode ����
        combineData.pressureMode25(i,:) = datas.statisPara25(5,:);
        %statisPara - std ��׼��
        combineData.pressureStd25(i,:) = datas.statisPara25(6,:);
        %statisPara - var ����
        combineData.pressureVar25(i,:) = datas.statisPara25(7,:);
        %statisPara - Skewness ƫ��
        combineData.pressureSkewness25(i,:) = datas.statisPara25(8,:);
        %statisPara - kurtosis �Ͷ�
        combineData.pressureKurtosis25(i,:) = datas.statisPara25(9,:);

        % pulsationValue
        combineData.pulsationValue(i,:) = datas.pulsationValue;
        % pulsationRate
        combineData.pulsationRate(i,:) = datas.pulsationRate;
    end


end
