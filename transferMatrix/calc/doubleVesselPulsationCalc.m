function [pressure1,pressure2,pressure3] = doubleVesselPulsationCalc( massFlowE,Frequency,time ...
    ,L1,L2,L3,Lv1,Lv2,l,Dpipe,Dv1,Dv2...
    ,sectionL1,sectionL2,sectionL3,varargin)
%计算管容管容的脉动
%   massFlowE1 经过fft后的质量流量，直接对质量流量进行去直流fft
%  长度 L1     l    Lv1   l   L2  l    Lv2   l     L3
%              __________         __________
%             |          |       |          |
%  -----------|          |-------|          |-------------
%             |__________|       |__________|  
%  直径 Dpipe       Dv1    Dpipe       Dv2          Dpipe
%   
% massFlowE经过傅里叶变换后的质量流量,仅仅是fft，不进行幅值修正
% Frequency 流量对应的频率，此长度是对应massFlowE的一半
% L 管长
% sectionL 管道脉动分段，最大值不能超过L
%  opt 附属设置，包括阻尼等
% if 0==L2
% L1,L2,L3,Lv1,Lv2,l,Dpipe,Dv1,Dv2,sectionL1,sectionL2,sectionL3,varargin
% end

pp=varargin;
k = nan;
oumiga = nan;
a = 345;%声速
% S = nan;
% Sv = nan;


isDamping = 0;
isOpening = 0;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%使用直管理论代替缓冲罐，那么缓冲罐时相当于三个直管拼接
mach = nan;
notMach = 0;%强制不使用mach
pressureBoundary2 = 0;%计算传递矩阵对应p2值

while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
            
        % case 'sv' %h缓冲罐截面
        %     Sv = val;
        % case 'dv' %h缓冲罐截面
        %     Dvessel = val;
            
        case 'a' %声速
            a = val; 
        case 'acousticvelocity' %声速
            a = val;
        case 'acoustic' %声速
            a = val;
        case 'isdamping' %是否包含阻尼
            isDamping = val;   
        case 'friction' %管道摩擦系数，计算阻尼系数时使用
            coeffFriction = val;
        case 'coefffriction' %管道摩擦系数，计算阻尼系数时使用
            coeffFriction = val;
        case 'meanflowvelocity' %平均流速，计算阻尼系数时使用
            meanFlowVelocity = val;
        case 'flowvelocity' %平均流速，计算阻尼系数时使用
            meanFlowVelocity = val;
        case 'mach' %马赫数，加入马赫数将会使用带马赫数的公式计算
            mach = val;
        case 'isusestaightpipe'
            isUseStaightPipe = val;%使用直管理论替代
        case 'usestaightpipe'
            isUseStaightPipe = val;
        case 'm'
            mach = val;
        case 'isopening'
            isOpening = val;
        case 'notmach' %强制用马赫数计算设定
            notMach = val;
        case 'pressureboundary2' %开口边界条件，p2的值，默认为0，如果不设置就相当于完全开口，这个属性必须在isOpening = 1的时候才生效
            pressureBoundary2 = val; 
        otherwise
            error('参数错误%s',prop);
    end
end
%如果用户没有定义k那么需要根据其他进行计算
% S = (pi.*Dpipe^2)./4;
% Sv1 = (pi.*Dv1.^2)./4;
% Sv2 = (pi.*Dv2.^2)./4;
if isnan(a)
    error('声速必须定义');
end

count = 1;
pressureE1 = [];
for i = 1:length(Frequency)
    f = Frequency(i);

    [matrix_3{count},tmp,coeffDamping] = straightPipeTransferMatrix(L3,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
	clear tmp;
    matrix_v2{count} = vesselTransferMatrix(Lv2,l,'f',f,'a',a,'D',Dpipe,'Dv',Dv2...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'isUseStaightPipe',isUseStaightPipe,'m',mach,'notmach',notMach);

    matrix_2{count} = straightPipeTransferMatrix(L2,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);

    matrix_v1{count} = vesselTransferMatrix(Lv1,l,'f',f,'a',a,'D',Dpipe,'Dv',Dv1...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'isUseStaightPipe',isUseStaightPipe,'m',mach,'notmach',notMach);

    matrix_1{count} = straightPipeTransferMatrix(L1,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
%     if 0 == L2
%         fprintf('\n============================================\n');
%         fprintf('Frequency:%g\n',f);
%         fprintf('\nmatrix_3:[%g,%g;%g,%g]',matrix_3{count}(1,1),matrix_3{count}(1,2),matrix_3{count}(2,1),matrix_3{count}(2,2));
%         fprintf('\nmatrix_v2:[%g,%g;%g,%g]',matrix_v2{count}(1,1),matrix_v2{count}(1,2),matrix_v2{count}(2,1),matrix_v2{count}(2,2));
%         fprintf('\nmatrix_2:[%g,%g;%g,%g]',matrix_2{count}(1,1),matrix_2{count}(1,2),matrix_2{count}(2,1),matrix_2{count}(2,2));
%         fprintf('\nmatrix_v1:[%g,%g;%g,%g]',matrix_v1{count}(1,1),matrix_v1{count}(1,2),matrix_v1{count}(2,1),matrix_v1{count}(2,2));
%         fprintf('\nmatrix_1:[%g,%g;%g,%g]',matrix_1{count}(1,1),matrix_1{count}(1,2),matrix_1{count}(2,1),matrix_1{count}(2,2));
%     end
    matrix_total = matrix_3{count}*matrix_v2{count}*matrix_2{count}*matrix_v1{count}*matrix_1{count};
    
    A = matrix_total(1,1);
    B = matrix_total(1,2);
    C = matrix_total(2,1);
    D = matrix_total(2,2);

    if(isOpening)
        %pressureE1(count) = ((-B/A)*massFlowE(count));
        pressureE1(count) = pressureBoundary2-(B*massFlowE(count)) / A;
    else
        pressureE1(count) = ((-D/C)*massFlowE(count));
    end
    count = count + 1;
end
%% 根据传递矩阵计算初始点脉动压力
%% 根据初始点脉动压力推演其余点脉动压力

count = 1;
plus1 = [];
pressure1 = [];
if ~isempty(sectionL1)
    for len = sectionL1
        count2 = 1;
        pTemp = [];
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx1 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            pressureEi(count2) = matrix_lx1(1,1)*pressureE1(count2) + matrix_lx1(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end       
        pressure1(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end

count = 1;
plus2 = [];
pressure2 = [];
if ~isempty(sectionL2)
    for len = sectionL2
        count2 = 1;
        pTemp = [];
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx2 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            matrix_Xl2_total = matrix_lx2  * matrix_v1{count2} * matrix_1{count2};
        
            pressureEi(count2) = matrix_Xl2_total(1,1)*pressureE1(count2) + matrix_Xl2_total(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end
        pressure2(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end

count = 1;
plus3 = [];
pressure3 = [];
if ~isempty(sectionL3)
    for len = sectionL3
        count2 = 1;
        pTemp = [];
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx3 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            matrix_Xl3_total = matrix_lx3 * matrix_v2{count2} * matrix_2{count2} * matrix_v1{count2} * matrix_1{count2};
        
            pressureEi(count2) = matrix_Xl3_total(1,1)*pressureE1(count2) + matrix_Xl3_total(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end
        pressure3(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end

end

