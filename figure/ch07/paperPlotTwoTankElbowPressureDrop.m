function paperPlotTwoTankElbowPressureDrop()
    [expTwoTankDataCells,expTwoTankCombineData] ...
        = loadExpDataFromFolder('D:\马屈杨\研究生\论文\share\【大论文】\[04]数据\实验原始数据\罐二在弯头处\双缓冲罐串联罐二当弯头420转0.1mpa');
    [exp05DDataCells,exp05DCombineData] ...
        = loadExpDataFromFolder('D:\马屈杨\研究生\论文\share\【大论文】\[04]数据\实验原始数据\罐二在弯头处\双罐串联罐二内插0.5D孔管入全开出全堵N=68+28开机420转0.1mpa');
    [exp1DDataCells,exp1DCombineData] ...
        = loadExpDataFromFolder('D:\马屈杨\研究生\论文\share\【大论文】\[04]数据\实验原始数据\罐二在弯头处\双罐串联罐二内插d20孔管入全开出全堵420转0.1mpa');
    [exp1DODataCells,exp1DOCombineData] ...
        = loadExpDataFromFolder('D:\马屈杨\研究生\论文\share\【大论文】\[04]数据\实验原始数据\罐二在弯头处\双缓冲罐串联罐二内插1D孔板开机420转带压');
    [exp05DPDataCells,exp05DPCombineData] ...
        = loadExpDataFromFolder('D:\马屈杨\研究生\论文\share\【大论文】\[04]数据\实验原始数据\罐二在弯头处\双罐串联罐二内插0.5D罐入全开出半开420转0.1mpa');
    figureExpPressureDrop({expTwoTankCombineData,exp05DCombineData,exp1DCombineData,exp1DOCombineData,exp05DPCombineData}...
        ,{'双罐罐二在弯头','内插孔管0.5D','内插孔管1D','内插孔板1D','内插管0.5D'}...
        ,[6,7]...
        ,'chartType','bar');
end