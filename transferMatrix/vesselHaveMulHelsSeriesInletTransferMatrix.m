function M = vesselHaveMulHelsSeriesInletTransferMatrix(V,lv,lc,dp,la1,la2,la,Din,varargin)

%内插孔管沿轴线开一排孔等效为多个亥姆霍兹共鸣器串联传递矩阵
%|————————|
%|la1 la  la  la2|
%|--- --- --- ---|  等效亥姆霍兹共鸣器的部分孔管管段
%|---------------|  孔管只在图示中开一排孔，个数为n
%|               |
%|————————|
% lv 共鸣器长
% lc 共鸣器连接管长
% dp 共鸣器连接管直径
% la1 该列孔距离腔体入口距离
% la  孔与孔之间的距离
% la2 该列孔距离腔体出口距离
% Din 孔管管径
%       __________                
%      |          |                   
%      |    V     | lv
%      |___    ___|     
%          |  | lc        
% _________|dp|__________                  
% _______________________    

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
sigma = 0;
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
        case 'mach' %马赫数，加入马赫数将会使用带马赫数的公式计算
            mach = val;
        case 'm'
            mach = val;
        case 'notmach'
            notMach = val;
        case 'sigma'
            sigma = val;
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
% S = pi .* Din.^2 ./ 4;
% Sv = pi .* Dv.^2 ./ 4;
% % mfvVessel = nan;
% if ~isnan(meanFlowVelocity)
%     if 1 == length(meanFlowVelocity)
%         mfvVessel = meanFlowVelocity.*S./Sv;
%         meanFlowVelocity = [meanFlowVelocity,mfvVessel];
%     end
% else 
%     error(['需指定流速，流速是管道进入缓冲罐时的流速，',...
%     '若需要指定缓冲罐流速，可以使用一个含有两个元素的向量[pipe，vessel]']);
% end
% mfvVessel = meanFlowVelocity(2);
if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('若需要计算阻尼，且没有定义阻尼系数，需定义“coeffFriction”管道摩擦系数');
        end
        if isnan(meanFlowVelocity)
            error('若需要计算阻尼，且没有定义阻尼系数，需定义“meanFlowVelocity”平均流速');
        end
        coeffDamping = (4.*coeffFriction.*meanFlowVelocity./Dpipe)./(2.*a);       
    end
end
if length(meanFlowVelocity) < 2
    if isnan(coeffDamping) < 2
        error('参数不全，至少meanFlowVelocity，或coeffDamping');
    end
end
if ~notMach%允许使用马赫
    if isnan(mach)
        if ~isnan(meanFlowVelocity)
            mach = meanFlowVelocity./a;
        else
            error('需要设定平均流速，请参考属性:meanflowvelocity');
        end
    end
else
    mach = nan;
end
optMachStraight.notMach = notMach;
optMachStraight.mach = mach(1);
optMachVessel.notMach = notMach;
% if(notMach)
%     if(length(mach) == 1)
%         optMachVessel.mach = mach(1);
%     end
% else
%     optMachVessel.mach = mach(2);
% end

M = haveMulHelsInletTransferMatrix(a,k,V,lv,lc,dp,la1,la2,la,Din,optDamping,optMachVessel,sigma);
end
%这里都是用直管等???
function M = haveMulHelsInletTransferMatrix(a,k,V,lv,lc,dp,la1,la2,la,Din,optDamping,optMach,sigma)
%内插孔管开一列孔等效为多个亥姆霍兹共鸣器串联传递矩阵
%|——————— |
%|   la1     la2|
%|--------- ----|  等效亥姆霍兹共鸣器的部分孔管管段
%|--------- ----|  孔管只在图示中开一列孔，个数为n
%|              |
%|——————— |
% lv 共鸣器长
% lc 共鸣器连接管长
% Dp 共鸣器连接管直径 dp*n 
% la1 该列孔距离腔体入口距离
% la2 该列孔距离腔体出口距离
%       __________                
%      |          |                   
%      |    V     | lv
%      |___    ___|     
%          |  | lc        
% _________|Dp|__________                  
% _______________________    
    if ~isstruct(optDamping)
        if isnan(optDamping)
            optDamping.isDamping = 0;
            optDamping.coeffDamping = 0;%注意，这个是缓冲罐的祝你系数
            optDamping.meanFlowVelocity = 10;
        end
    end
    if ~isstruct(optMach)
        if isnan(optMach)
            optMach.notMach = 1;
            optMach.mach = 0;
        end
    end
  
    Mv1 = straightPipeTransferMatrix(la1,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    Mv2 = straightPipeTransferMatrix(la2,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    Mv = straightPipeTransferMatrix(la,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDamping...
                ,'mach',optMach.mach,'notmach',optMach.notMach);
    %急??变径的传递矩???
%     Sv = pi.* Dv.^2 ./ 4;
%     Spipe = pi.* Dpipe.^2 ./ 4; 
    %innerPML = [1,0;0,1]; 
    %亥姆霍兹共鸣器传递矩???
    HM = HelmholtzResonatorTransferMatrix_nInParallel(V,lv,lc,dp,'a',a,'k',k,'sigma',sigma);
    M = Mv2 * HM * Mv * HM * Mv * HM * Mv * HM * Mv1;%假定开4个孔
end