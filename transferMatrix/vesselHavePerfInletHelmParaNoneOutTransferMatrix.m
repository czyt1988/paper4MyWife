function M = vesselHavePerfInletHelmParaNoneOutTransferMatrix(Dpipe,Dv,l,Lv,...
    lc,dp,Lin,n1,la1,la2,Din,Lout,V,lv,varargin)
%�������������ӿ׹�,Lin���ֵ�ЧΪ�����ĺ�ķ���ȹ�����.Lout����Ϊ�ڲ忪�ڹܣ�������
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             | lc dp(n1) |                     |
%             |___ _______|___________          |     
%  -----------|___ _______ ___________ Din      |----------
%             |la1 lp1 la2|                     |
%             |___________|_____________________|       
%                  Lin         Lout
%    Dpipe                   Dv                     Dpipe 
%              
%
% Lin �ڲ�׹���ڶγ��� 
% Lout�ڲ�ܳ��ڶγ���
% lc  �׹ܱں�
% dp  �׹�ÿһ���׿׾�
% n1  �׹���ڶο��׸����� 
% la1 �׹���ڶξ���ڳ��� 
% la2 �׹���ڶξ���峤��
% lp1 �׹���ڶο��׳���
% Din �׹ܹܾ���
% V ��Ч��ķ���ȹ������������
% lv ��Ч��ķ���ȹ��������ȣ�
% xSection1 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��
pp=varargin;
k = nan;
oumiga = nan;
f = nan;
a = nan;%����
isDamping = 1;%Ĭ��ʹ������
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%ʹ��ֱ�����۴��滺��ޣ���ô�����ʱ�൱������ֱ��ƴ��
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
coeffM1 = nan;%�׹�������
coeffM2 = nan;%�����������
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
        case 'isdamping' %�Ƿ��������
            isDamping = val;   
        case 'coeffdamping' %����ϵ����
            coeffDamping = val;
        case 'damping' %����ϵ����
            coeffDamping = val;
        case 'friction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'coefffriction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
            coeffFriction = val;
        case 'meanflowvelocity' %ƽ����
            meanFlowVelocity = val;
        case 'flowvelocity' %ƽ����
            meanFlowVelocity = val;
        case 'isusestaightpipe'
            isUseStaightPipe = val;%ʹ��ֱ���������
        case 'usestaightpipe'
            isUseStaightPipe = val;
        case 'm1'
            coeffM1 = val;
        case 'm2'
            coeffM2 = val;
        case 'mach' %�ܵ�����������������������ʹ�ô��������Ĺ�ʽ����
            mach = val;
        case 'notmach'
            notMach = val;
        otherwise
       		error('��������%s',prop);
    end
end

if isnan(a)
    error('���ٱ��붨��');
end
if isnan(k)
	if isnan(oumiga)
		if isnan(f)
			error('��û������kʱ�����ٶ���oumiga,f,acoustic�е�����');
		else
			oumiga = 2.*f.*pi;
		end
	end
	k = oumiga./a;
end
%��������
S = pi .* Dpipe.^2 ./ 4;
Sv = pi .* Dv.^2 ./ 4;%����޽����
Sp = pi*Din.^2./4;%�׹ܹܾ������
Sv_p = Sv-Sp;%ȥ���׹ܵĻ���޽����
Dv_inner = (4*Sv_p/pi).^0.5;%��������ֱ��
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
    error(['��ָ�����٣������ǹܵ����뻺���ʱ�����٣�',...
    '����Ҫָ����������٣�����ʹ��һ������4��Ԫ�ص�����[pipe��vessel,vessel_Inner,InnerPipe]']);
end

if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰coeffFriction���ܵ�Ħ��ϵ��');
        end
        if isnan(meanFlowVelocity)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰meanFlowVelocity��ƽ������');
        end
        if length(meanFlowVelocity) < 4
            error('��meanFlowVelocity��ƽ�����ٵĳ��ȹ�С������Ϊ4');
        end
        Dtemp = [Dpipe,Dv,Dv_inner,Din];
        coeffDamping = (4.*coeffFriction.*meanFlowVelocity./Dtemp)./(2.*a);       
    end
    if length(coeffDamping)<4
        %���뿼��4��
        coeffDamping(2) = (4.*coeffFriction.*mfvVessel./Dv)./(2.*a);
        coeffDamping(3) = (4.*coeffFriction.*mfvVessel./Dv_inner)./(2.*a);
        coeffDamping(4) = (4.*coeffFriction.*mfvVessel./Din)./(2.*a);
    end
end


if ~notMach%����ʹ������,mach(1)ֱ��mach��mach(2)�����mach:mach(3)���ڲ�ܵĻ���޵�mach:mach(4)�ڲ�ܵ�mach
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

optDamping.coeffDampVessel = coeffDamping(2);%����޵�����ϵ��
optDamping.mfvVessel = meanFlowVelocity(2);

optDamping.coeffDampVesselWithInnerPipe = coeffDamping(3);%����޵�����ϵ��
optDamping.mfvVesselWithInnerPipe = meanFlowVelocity(3);

optDamping.coeffDampInnerPipe = coeffDamping(4);%����޵�����ϵ��
optDamping.mfvInnerPipe = meanFlowVelocity(4);



M1 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMach.machStraight,'notmach',optMach.notMach);
M2 = straightPipeTransferMatrix(l,'k',k,'d',Dpipe,'a',a...
      ,'isDamping',isDamping,'coeffDamping',coeffDamping(1) ...
        ,'mach',optMach.machStraight,'notmach',optMach.notMach);
    
Mv = havePerforatedPipeInletHelmParaNoneOutTransferMatrix(a,k,Dv,Lv,...
    lc,dp,Lin,n1,la1,la2,Din,Lout,V,lv,optDamping,optMach);
M = M2 * Mv * M1;
end
function M = havePerforatedPipeInletHelmParaNoneOutTransferMatrix(a,k,Dv,Lv ...
    ,lc,dp,Lin,n1,la1,la2,Din,Lout,V,lv,optDamping,optMach)
%�������������ӿ׹�,���׸��������Ե�ЧΪ��ķ���ȹ�����
%      L1     l                 Lv              l    L2  
%              _________________________________        
%             |    dp(n1) |                     |
%             |___ _ _ ___|___________ lc       |     
%  -----------|___ _ _ ___ ___________ Din      |----------
%             |la1 lp1 la2|                     |
%             |___________|_____________________|       
%                  Lin         Lout
%    Dpipe                   Dv                     Dpipe 
%section  1                              2   ����޷ֵ�������              
%
% Lin �ڲ�׹���ڶγ��� 
% Lout�ڲ�׹ܳ��ڶγ���
% lc  �׹ܱں�
% dp  �׹�ÿһ���׿׾�
% n1  �׹���ڶο��׸����� 
% la1 �׹���ڶξ���ڳ��� 
% la2 �׹���ڶξ���峤��
% lp1 �׹���ڶο��׳���
% Din �׹ܹܾ���
% xSection1�׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��

   if ~isstruct(optDamping)
        if isnan(optDamping)
            error('optDamping����Ϊ��');
        end
    end
    if ~isstruct(optMach)
        if isnan(optMach)
            error('optMach����Ϊ��');
        end
    end
    % ������ڲ����׹ܵĲ���
%     Lin = la1 + lp1 + la2;
    Lv1 = Lv - Lin - Lout;%������ڲ�׹��޽��ӵ�����
   
    if ((Lv1 < 0))
        error('���ȳߴ�����');
    end
    Mv1 = straightPipeTransferMatrix(Lv1,'k',k,'d',Dv,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampVessel...
                ,'mach',optMach.machVessel,'notmach',optMach.notMach);
    %�ڲ��ǻ�崫�ݾ���-�ұ�
    innerRM = innerPipeCavityTransferMatrix(Dv,Din,Lout,'a',a,'k',k);
    %�ڲ�׹ܸ�������Ӧla2+Lout
    Mstr2 = straightPipeTransferMatrix(la2,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampInnerPipe...
                ,'mach',optMach.machInnerPipe,'notmach',optMach.notMach);
   %�ڲ�׹���ڶζ�Ӧlp1����ЧΪ������n����ķ���ȹ�����
    MH1 = HelmholtzResonatorTransferMatrix_nInParallel(V,lv,lc,dp,n1...
        ,'k',k,'a',a);
    %�ڲ�׹�����ڹ����Ӳ��ֶ�Ӧla1
    Mstr1 = straightPipeTransferMatrix(la1,'k',k,'d',Din,'a',a,...
                'isDamping',optDamping.isDamping,'coeffDamping',optDamping.coeffDampInnerPipe...
                ,'mach',optMach.machInnerPipe,'notmach',optMach.notMach);
    M = Mv1 * innerRM * Mstr2 * MH1 * Mstr1;
end