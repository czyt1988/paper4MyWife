%% 数据预处理 - 处理一个已经进行预处理的联合数据，就是后缀带combine的数据结构体，和缓冲罐的数据进行结合
clc;
close all;
clear;
currentPath = fileparts(mfilename('fullpath'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%下面是需要设置的参数，本程序仅在此需要更改参数，其他地方不需要更改
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataPath = getDataPath();
rpm = 420;%指定转速，以便做对比时选择对应转速的缓冲罐进行对比
combineDataStructPath = fullfile(dataPath,'实验原始数据\缓冲罐内置孔板0.5D罐中间\开机420转带压_combine.mat');
combineDataStruct = load(combineDataStructPath);
combineDataStruct = combineDataStruct.combineDataStruct;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%检查一下，防止转速没有设置或设置错误
rpmIndex = strfind(combineDataStructPath,'转');
rpmText = combineDataStructPath(rpmIndex(end)-3:rpmIndex(end)-1);
tmp = str2num(rpmText);
if tmp ~= rpm
    btnText1 = '!!!~ 继续 ~ !!![慎重选择]';
    btnText2 = '取消，再看看';
    button = questdlg('转速设置和检查的文件夹命名转速不一致,是否继续忽略警告,建议取消再好好检查！'...
    ,'询问'...
    ,btnText1,btnText2,btnText2...
    );
    if ~strcmp(button,btnText1)
        return;
    end
end


%计算缓冲罐的数据
vesselCombineDataStruct = getPureVesselCombineDataStruct(rpm);
combineDataStruct = calcSuppressionLevel(combineDataStruct,vesselCombineDataStruct,'rawData');
combineDataStruct = calcSuppressionLevel(combineDataStruct,vesselCombineDataStruct,'subSpectrumData');
combineDataStruct = calcSuppressionLevel(combineDataStruct,vesselCombineDataStruct,'saMainFreFilterStruct');
%保持结果

save(combineDataStructPath,'combineDataStruct');

msgbox('计算完成');