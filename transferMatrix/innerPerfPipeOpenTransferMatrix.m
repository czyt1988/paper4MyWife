function M = innerPerfPipeOpenTransferMatrix(n2,dp2,Din,Dv,lp2,lc,lb1,lb2,xSection2,varargin)
%内插孔管，孔管开孔数不是非常少，无法等价为亥姆霍兹共鸣器，且孔管出口处封闭，缓冲罐全开,理论来自书85页
% n2 孔管穿孔数
% dp 孔管穿孔孔径
% Din 穿管管径
% lp2 穿孔部分长度
% k 波数
% M1 管内的马赫数
% R0 系数默认0.0055
% lc 孔管壁厚
% xSection2 孔管每圈孔的间距，从0开始算，x的长度为孔管孔的圈数+1，x的值是当前一圈孔和上一圈孔的距离，如果间距一样，那么x里的值都一样
% xSection2 =[0,1,1,1,1,1,1,1,1,1]
%下述传递矩阵只表示带孔部分
%      -----------------------------------|
%     |----- -- -- --dp2---|              |lc
%-----|   Din              |              |------
%     |----- -- --n2-- ----|              |
%      lb1_______lp2____lb2_______________|
%
% lp 孔管长度（从第一个开孔算起，到最后一个开孔结束，见书79页图4.5.1）

pp = varargin;
k = nan;
oumiga = nan;
f = nan;
a = 345;%声速
R0 = 0.0055;% ?
meanFlowVelocity = nan;
M1 = nan;%管道马赫数
M2 = nan;%缓冲罐马赫数
while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
        case 'k' %波数
        	k = val;
        case 'oumiga' %圆频率
        	oumiga = val;
        case 'f' %脉动频率
        	f = val;
        case 'a'
        	a = val;
        case 'acousticvelocity'
        	a = val;
        case 'acoustic'
        	a = val;
        case 'meanflowvelocity'
            meanFlowVelocity = val;
        case 'm1'
            M1 = val;
        case 'm2'
            M2 = val;
        case 'r0'
            R0 = val;
        otherwise
       		error('参数错误%s',prop);
    end
end
%如果用户没有定义k那么需要根据其他进行计算
if isnan(k)
	if isnan(oumiga)
		if isnan(f)
			error('在没有输入k时，至少需要定义oumiga,f,acoustic中的两个');
		else
			oumiga = 2.*f.*pi;
		end
	end
	k = oumiga./a;
end
Sp = pi*Din.^2./4;%孔管管径截面积
Sv = pi*Dv.^2./4;%缓冲罐截面积
if isnan(M1)
    if isnan(meanFlowVelocity)
        error('流速必须给定');
    end
    if isnan(a)
        error('声速必须给定');
    end
    M1 = meanFlowVelocity./a;
    M2 = M1 .* Sp ./ (Sv-Sp);
end
coeffD = calcD(n2,dp2,Din,Dv,lp2,k,M1,M2,R0,lc,xSection2);
coeffR = calcR(coeffD);
coeffT = calcT(k,lb1,lb2,coeffR);
coeffFM = coeffT(2,2)*coeffT(1,1)-coeffT(1,2)*coeffT(2,1);

A = coeffT(2,2)./coeffFM;
B = -(a./Sp) .* (coeffT(1,2)./coeffFM);
C = ((Sv-Sp)./a) .* (coeffT(2,1)./(-coeffFM));
D = -((Sv-Sp)./Sp) .* (coeffT(1,1)./(-coeffFM));
% A = coeffT(2,2)./coeffFM;
% B = (-a./Sp)*coeffT(1,2)./coeffFM;
% C = (Sp./a*coeffT(2,1))./(-coeffFM);
% D = -coeffT(1,1)./(-coeffFM);
M = [A,B;C,D];%[p2,m2]孔管出口端（开孔部分）所在缓冲罐内的压力=M*[p1,m1]
end
 
function D = calcD(n2,dp2,Din,Dv,lp2,k,M1,M2,R0,lc,xSection2)
% n2 孔管穿孔数
% dp 孔管穿孔孔径
% Din 穿管管径
% lp2 穿孔部分长度
% k 波数
% M1 管内的马赫数
% R0 系数默认0.0055
% lc 孔管壁厚
% xSection2 孔管每圈孔的间距，从0开始算，x的长度为孔管孔的圈数+1，x的值是当前一圈孔和上一圈孔的距离，如果间距一样，那么x里的值都一样
% xSection2=[0,1,1,1,1,1,1,1,1,1]

    bp2 = n2.*dp2^2./(4.*Din.*lp2);%开孔率
    rp = dp2/2;
%     kr = k.*rp;
%     if kr <= M1 %M1为管内马赫数    
%         Cg = 12^(k.*rp./(M1-1));
%     else
%         Cg = 1;
%     end  
    sig0 = calcSigma0(bp2);
    if M1 == 0
         kp = (R0+1i.*k.*(lc+sig0.*dp2))./bp2;%kp为穿孔声阻抗率
    elseif M1>0
        kp = (R0 + 2.48.*(1-bp2).*(M1.^(1.04+40.*dp2)) + 1i.*k.*(lc+(1-(1+398.34.*dp2).*((1-bp2).^1.44).*(M1.^0.72)).*sig0.*dp2))./bp2;%通过流
        %kp = (R0+0.48.*abs(k.*rp-M1)+1i.*k.*(lc+Cg.*sig0.*dp))./bp2;%掠过流
    else
        error('马赫数M1不能小于0');
    end
    
    a1 = -2.*M1.*(1i.*k+2./(Din.*kp))./(1-M1^2);
    a2 = 1.*(k^2-4.*1i.*k./(Din.*kp))./(1-M1^2);
    a3 = 4.*M1./(Din.*kp)./(1-M1^2);
    a4 = 4.*1i.*k./(Din.*kp)./(1-M1^2);
    a5 = M2.*4.*Din./((Dv.^2-(Din+2.*lc).^2).*kp)./(1-M2^2);
    a6 = 4.*1i.*k.*Din./((Dv.^2-(Din+2.*lc).^2).*kp)./(1-M2^2);
    a7 = -2.*M2.*(1i.*k+2.*Din./((Dv.^2-(Din+2.*lc).^2).*kp))./(1-M2^2);
    a8 = (k.^2-4.*1i.*k.*Din./((Dv.^2-(Din+2.*lc).^2).*kp))./(1-M2^2);
    B = [-a1,-a3,-a2,-a4;-a5,-a7,-a6,-a8;1,0,0,0;0,1,0,0];
    [V,W] = eig(B);
    count = 1;
    for x = xSection2
            D{count} = [V(3,1).*exp(W(1,1).*x),V(3,2).*exp(W(2,2).*x),V(3,3).*exp(W(3,3).*x),V(3,4).*exp(W(4,4).*x);...
            -V(1,1).*exp(W(1,1).*x)./(1i.*k+M1.*W(1,1)),-V(1,2).*exp(W(2,2).*x)./(1i.*k+M1.*W(2,2)),...
            -V(1,3).*exp(W(3,3).*x)./(1i.*k+M1.*W(3,3)),-V(1,4).*exp(W(4,4).*x)./(1i.*k+M1.*W(4,4));...
            V(4,1).*exp(W(1,1).*x),V(4,2).*exp(W(2,2).*x),V(4,3).*exp(W(3,3).*x),V(4,4).*exp(W(4,4).*x);...
            -V(2,1).*exp(W(1,1).*x)./(1i.*k+M2.*W(1,1)),-V(2,2).*exp(W(2,2).*x)./(1i.*k+M2.*W(2,2)),...
            -V(2,3).*exp(W(3,3).*x)./(1i.*k+M2.*W(3,3)),-V(2,4).*exp(W(4,4).*x)./(1i.*k+M2.*W(4,4));...
           ];
       count = count + 1;
    end

end

function sig0 = calcSigma0(bp)
    sig0 = 0.8216*(1-1.5443*bp^0.5+0.3508*bp+0.1935*bp^1.5);%穿孔管的端部修正系数（穿孔率小于40%）
%     if bp >= 0.4
%     	error('穿孔率不能大于40%');
%     end
% if 0<sqrt(bp./pi) && sqrt(bp./pi)<=0.25
%     sig0 = 0.85.*(1-2.34.*sqrt(bp./pi));
% elseif 0.25<sqrt(bp./pi) && sqrt(bp./pi)<=0.5
%     sig0 = 0.668.*(1-1.9.*sqrt(bp./pi));    
% end
end

function R = calcR(D)
%计算出来的R是总的R，是R1，R2……Rn乘起来的结果
    sizeD = length(D);
    for i=1:sizeD
        if i==sizeD
            break;
        end
        RSection{i} = D{i}*inv(D{i+1});
    end
    sizeR = length(RSection);
     R = RSection{1};
    for i=2:sizeR
        R = R * RSection{i};
    end
end

function Tmn = calcTmn(m,n,k,lb1,lb2,R)
%lb1 靠近入口无穿孔距离
%lb2 靠近出口无穿孔距离
    P = (R(m,1)+1i.*R(m,2).*tan(k.*lb2)).*(R(4,n+2)+1i.*R(3,n+2).*tan(k.*lb1));
    Q = R(4,1)+1i.*R(4,2).*tan(k.*lb2)+1i.*tan(k.*lb1).*(R(3,1)+1i.*R(3,2).*tan(k.*lb2));
    Tmn = R(m,n+2)-(P)./(Q);
end

function T = calcT(k,lb1,lb2,R)
    T = [calcTmn(1,1,k,lb1,lb2,R),calcTmn(1,2,k,lb1,lb2,R);...
        calcTmn(2,1,k,lb1,lb2,R),calcTmn(2,2,k,lb1,lb2,R)];
end