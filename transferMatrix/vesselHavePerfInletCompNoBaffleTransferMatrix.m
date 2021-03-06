function M = vesselHavePerfInletCompNoBaffleTransferMatrix(Dpipe,Dv,l,Lv,...
    lc,dp,lp2,n2,lb1,lb2,Din,xSection2,varargin)
%缓冲罐内入口连接孔管，孔管末端封闭，验证西交大论文
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             |    dp(n2)                      |
%             |___ _ _ _ _ _ _ ___ lc          |     
%  -----------|___ _ _ _ _ _ _ ___|Din         |----------
%             |lb1     lp2     lb2             |
%             |________________________________|       
%                    Lin         
%    Dpipe                   Dv                     Dpipe 
%              
%
% Lin 内插孔管入口段长度 
% Lout内插孔管出口段长度
% lc  孔管壁厚
% dp  孔管每一个孔孔径
% n1  孔管入口段开孔个数；    n2  孔管出口段开孔个数
% la1 孔管入口段距入口长度 
% la2 孔管入口段距隔板长度
% lb1 孔管出口段距隔板长度
% lb2 孔管出口段距开孔长度
% lp1 孔管入口段开孔长度
% lp2 孔管出口段开孔长度
% Din 孔管管径；
% xSection1，xSection2 孔管每圈孔的间距，从0开始算，x的长度为孔管孔的圈数+1，x的值是当前一圈孔和上一圈孔的距离，如果间距一样，那么x里的值都一样
pp=varargin;
k = nan;
oumiga = nan;
f = nan;
a = nan;%声速
isDamping = 1;%默认使用阻尼
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%使用直管理论代替缓冲罐，那么缓冲罐时相当于三个直管拼接
mach = nan;
notMach = 0;%强制不使用mach
R0 = 0.0055;%计算孔管声阻抗率用到的系数
coeffM1 = nan;%孔管马赫数
coeffM2 = nan;%缓冲罐马赫数
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'k'
        	k = val;
        case 'oumiga'
        	oumiga = val;
        case 'f'
        	f = val;
        case 'a'
        	a = val;
        case 'acousticvelocity'
        	a = val;
        case 'acoustic'
        	a = val;
        case 'isdamping' %是否包含阻尼
            isDamping = val;   
        case 'coeffdamping' %阻尼系数，
            coeffDamping = val;
        case 'damping' %阻尼系数，
            coeffDamping = val;
        case 'friction' %管道摩擦系数，计算阻尼系数时使用
            coeffFriction = val;
        case 'coefffriction' %管道摩擦系数，计算阻尼系数时使用
            coeffFriction = val;
        case 'meanflowvelocity' %平均流
            meanFlowVelocity = val;
        case 'flowvelocity' %平均流
            meanFlowVelocity = val;
        case 'isusestaightpipe'
            isUseStaightPipe = val;%使用直管理论替代
        case 'usestaightpipe'
            isUseStaightPipe = val;
        case 'm1'
            coeffM1 = val;
        case 'm2'
            coeffM2 = val;
        case 'mach' %管道马赫数，加入马赫数将会使用带马赫数的公式计算
            mach = val;
        case 'notmach'
            notMach = val;
        otherwise
       		error('参数错误%s',prop);
    end
end

if isnan(a)
    error('声速必须定义');
end
if isnan(k)
	if isnan(oumiga)
		if isnan(f)
			error('在没有输入k时，至少定义oumiga,f,acoustic中的两个');
		else
			oumiga = 2.*f.*pi;
		end
	end
	k = oumiga./a;
end
%流速修正
S = pi .* Dpipe.^2 ./ 4;
Sv = pi .* Dv.^2 ./ 4;%缓冲罐截面积
Sp = pi*Din.^2./4;%孔管管径截面积
Sv_p = Sv-Sp;%去除孔管的缓冲罐截面积
Dv_inner = (4*Sv_p/pi).^0.5;%计算名义直径
mfvVessel = nan;
mfvInnerPipe = nan;
mfvVessel_Inner = nan;
if ~isnan(meanFlowVelocity)
    if 1 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity*S/Sv;
        mfvVessel_Inner = meanFlowVelocity*S/Sv_p;
        mfvInnerPipe = meanFlowVelocity*S/Sp;
        meanFlowVelocity = [meanFlowVelocity,mfvVessel,mfvVessel_Inner,mfvInnerPipe];
    elseif 2 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity(2);
        mfvVessel_Inner = meanFlowVelocity*S/Sv_p;
        mfvInnerPipe = meanFlowVelocity*S/Sp;
        meanFlowVelocity = [meanFlowVelocity,mfvVessel_Inner,mfvInnerPipe];
    elseif 3 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity(2);
        mfvVessel_Inner = meanFlowVelocity(3);
        mfvInnerPipe = meanFlowVelocity*S/Sp;
        mfvInnerPipe = [meanFlowVelocity,mfvInnerPipe];
    elseif 4 == length(meanFlowVelocity)
        mfvVessel = meanFlowVelocity(2);
        mfvVessel_Inner = meanFlowVelocity(3);
        mfvInnerPipe = meanFlowVelocity(4);
    end
else 
    error(['需指定流速，流速是管道进入缓冲罐时的流速，',...
    '若需要指定缓冲罐流速，可以使用一个含有4个元素的向量[pipe，vessel,vessel_Inner,InnerPipe]']);
end

if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('若需要计算阻尼，且没有定义阻尼系数，需定义“coeffFriction”管道摩擦系数');
        end
        if isnan(meanFlowVelocity)
            error('若需要计算阻尼，且没有定义阻尼系数，需定义“meanFlowVelocity”平均流速');
        end
        if length(meanFlowVelocity) < 4
            error('“meanFlowVelocity”平均流速的长度过小，必须为4');
        end
        Dtemp = [Dpipe,Dv,Dv_inner,Din];
        coeffDamping = (4.*coeffFriction.*meanFlowVelocity./Dtemp)./(2.*a);       
    end
    if length(coeffDamping)<4
        %必须考虑4个
        coeffDamping(2) = (4.*coeffFriction.*mfvVessel./Dv)./(2.*a);
        coeffDamping(3) = (4.*coeffFriction.*mfvVessel./Dv_inner)./(2.*a);
        coeffDamping(4) = (4.*coeffFriction.*mfvVessel./Din)./(2.*a);
    end
end


if ~notMach%允许使用马赫,mach(1)直管mach，mach(2)缓冲罐mach:mach(3)带内插管的缓冲罐的mach:mach(4)内插管的mach
    if isnan(mach)
        if ~isnan(meanFlowVelocity)
            mach = meanFlowVelocity./a;
        end
    elseif(length(mach) == 1)
          mach(2) = meanFlowVelocity(2)/a;
    elseif(length(mach) == 2)
          mach(3) = meanFlowVelocity(3)/a;
    elseif(length(mach) == 3)
          mach(4) = meanFlowVelocity(4)/a;
    end
else
    mach = nan;
end
optMach.notMach = notMach;
optMach.machStraight = mach(1);
optMach.machVessel = mach(2);
optMach.machVesselWithInnerPipe = mach(3);
optMach.machInnerPipe = mach(4);

optDamping.isDamping = isDamping;
optDamping.coeffDampStraight = coeffDamping(1);
optDamping.mfvStraight = meanFlowVelocity(1);

optDamping.coeffDampVessel = coeffDamping(2);%缓冲罐的阻尼系数
optDamping.mfvVessel = meanFlowVelocity(2);

optDamping.coeffDampVesselWithInnerPipe = coeffDamping(3);%缓冲罐的阻尼系数
optDamping.mfvVesselWithInnerPipe = meanFlowVelocity(3);

optDamping.coeffDampInnerPipe = coeffDamping(4);%缓冲罐的阻尼系数
optDamping.mfvInnerPipe = meanFlowVelocity(4);



M1 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMach.machStraight,'notmach',optMach.notMach);
M2 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMach.machStraight,'notmach',optMach.notMach);
    
Mv = havePerforatedPipeInletCompNoBaffleTransferMatrix(a,k,Dv,Dv_inner,Lv,...
    lc,dp,lp2,n2,lb1,lb2,Din,xSection2,optDamping,optMach);
M = M2 * Mv * M1;
end
function M = havePerforatedPipeInletCompNoBaffleTransferMatrix(a,k,Dv,Dv_inner,Lv ...
    ,lc,dp,lp2,n2,lb1,lb2,Din,xSection2,optDamping,optMach)
%缓冲罐内入口连接孔管，孔管末端封闭，验证西交大论文
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             |    dp(n2)                      |
%             |___ _ _ _ _ _ _ ___ lc          |     
%  -----------|___ _ _ _ _ _ _ ___|Din         |----------
%             |lb1     lp2     lb2             |
%             |________________________________|       
%                    Lin         
%    Dpipe                   Dv                     Dpipe 
%section  1                              2   缓冲罐分的两个区              
%
% Lin 内插孔管入口段长度 
% Lout内插孔管出口段长度
% lc  孔管壁厚
% dp  孔管每一个孔孔径
% n1  孔管入口段开孔个数；    n2  孔管出口段开孔个数
% la1 孔管入口段距入口长度 
% la2 孔管入口段距隔板长度
% lb1 孔管出口段距隔板长度
% lb2 孔管出口段距开孔长度
% lp1 孔管入口段开孔长度
% lp2 孔管出口段开孔长度
% Din 孔管管径；
% xSection1，xSection2 孔管每圈孔的间距，从0开始算，x的长度为孔管孔的圈数+1，x的值是当前一圈孔和上一圈孔的距离，如果间距一样，那么x里的值都一样

   if ~isstruct(optDamping)
        if isnan(optDamping)
            error('optDamping不能为空');
        end
    end
    if ~isstruct(optMach)
        if isnan(optMach)
            error('optMach不能为空');
        end
    end
    % 缓冲罐内不含孔管的部分
    Lin = lb1 + lp2 + lb2;
    Lv1 = Lv - Lin;%缓冲罐内插孔管无交接的区域长
   
    if ((Lv1 < 0))
        error('长度尺寸有误');
    end
    Mv1 = straightPipeTransferMatrix(Lv1,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampVessel...
                ,'mach',optMach.machVessel,'notmach',optMach.notMach);
    %内插孔管出口段对应lp2
    Mp2 = innerPerfPipeOpenTransferMatrix(n2,dp,Din,Dv,lp2,lc,lb1,lb2,xSection2...
        ,'k',k,'a',a,'meanflowvelocity',optDamping.mfvInnerPipe...
        ,'M1',optMach.machInnerPipe,'M2',optMach.machVesselWithInnerPipe);
    %内插孔管隔板区对应la2+lb1
    Mstr2 = straightPipeTransferMatrix(lb2,'k',k,'d',Dv_inner,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampInnerPipe...
                ,'mach',optMach.machInnerPipe,'notmach',optMach.notMach);
    %内插孔管与进口管连接部分对应la1
    Mstr1 = straightPipeTransferMatrix(lb1,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampInnerPipe...
                ,'mach',optMach.machInnerPipe,'notmach',optMach.notMach);
%     %内插管腔体传递矩阵-右边对应lb1+lp2
%     Mca = innerPipeCavityTransferMatrix(Dv,Din,lb1+lp2,'a',a,'k',k);
    M = Mv1 * Mstr2 * Mp2 * Mstr1;
end