function [pressure1,pressure2] = vesselHaveOrificePulsationCalc( massFlowE,Frequency,time ...
,L1,L2,Lv1,Lv2,l,Dpipe,Dv1,Dv2,d,sectionL1,sectionL2,varargin)
%含孔板缓冲罐的气流脉动计算
%   Detailed explanation goes here
%  L1  l    Lv1     Lv2   l  L2
%        __________________
%       |         |        |
% ------|     V1   d    V2 |-------
%       |_________|________|
%    Dpipe  Dv1    d   Dv2    Dpipe 
pp=varargin;
k = nan;
oumiga = nan;
a = 345;%声速

isDamping = 1;
isOpening = 1;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%使用直管理论代替缓冲罐，那么缓冲罐时相当于三个直管拼接
mach = nan;
% coeffDamping = 0.1;
notMach = 0;%强制不使用mach
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
%         case 'orificecoeffdamping' %阻尼系数，是一个长度为2的向量，第一个代表直管的，第二个代表缓冲罐的
%             orificeCoeffDamping = val;
%         case 'coeffdamping' %阻尼系数，是一个长度为2的向量，第一个代表直管的，第二个代表缓冲罐的
%             coeffDamping = val;
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
        case 'notmach' %强制用马赫数计算设定
            notMach = val;
        case 'isopening'%管道末端是否为无反射端(开口)，如果为0，就是为闭口，无流量端
            isOpening = val;
        otherwise
            error('参数错误%s',prop);
    end
end

if isnan(a)
    error('声速必须定义');
end

count = 1;
pressureE1 = [];

S = pi.*Dpipe.^2./4;
Sv = pi.*Dv2.^2./4;
mfvVessel = meanFlowVelocity.*S./Sv;


for i = 1:length(Frequency)
    f = Frequency(i);

    matrix_2{count} = straightPipeTransferMatrix(L2,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);

     matrix_v2{count} = halfVesselTransferMatrix(Lv2,l,0,'f',f,'a',a,'D',Dpipe,'Dv',Dv2...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'isUseStaightPipe',isUseStaightPipe,'m',mach,'notmach',notMach);

    
     matrix_orifice{count} = orificeTransferMatrix(Dv2,d,mfvVessel);
%     sudMach = (d^2/Dpipe^2*meanFlowVelocity)/a;
%     matrix_orifice{count} = sudReduceTransferMatrix(pi*d^2/4,pi*Dv2^2/4,1,a,'coeffDamping',orificeCoeffDamping,'mach',sudMach)...
%      * sudReduceTransferMatrix(pi*Dv2^2/4,pi*d^2/4,0,a,'coeffDamping',orificeCoeffDamping,'mach',sudMach);
    
     matrix_v1{count} = halfVesselTransferMatrix(Lv1,l,1,'f',f,'a',a,'D',Dpipe,'Dv',Dv1...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'isUseStaightPipe',isUseStaightPipe,'m',mach,'notmach',notMach);

    matrix_1{count} = straightPipeTransferMatrix(L1,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);
    matrix_total = matrix_2{count}*matrix_v2{count}*matrix_orifice{count}*matrix_v1{count}*matrix_1{count};

    A = matrix_total(1,1);
    B = matrix_total(1,2);
    C = matrix_total(2,1);
    D = matrix_total(2,2);
    if(isOpening)
        pressureE1(count) = ((-B/A)*massFlowE(count));
    else
        pressureE1(count) = ((-D/C)*massFlowE(count));
    end
    count = count + 1;
end

count = 1;
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
            matrix_Xl2_total = matrix_lx2  * matrix_v2{count2} * matrix_orifice{count2} * matrix_v1{count2} * matrix_1{count2};
        
            pressureEi(count2) = matrix_Xl2_total(1,1)*pressureE1(count2) + matrix_Xl2_total(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end
        pressure2(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end
end

