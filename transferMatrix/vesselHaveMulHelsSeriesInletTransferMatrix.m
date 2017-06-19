function M = vesselHaveMulHelsSeriesInletTransferMatrix(V,lv,lc,dp,la1,la2,la,Din,varargin)

%�ڲ�׹������߿�һ�ſ׵�ЧΪ�����ķ���ȹ������������ݾ���
%|����������������|
%|la1 la  la  la2|
%|--- --- --- ---|  ��Ч��ķ���ȹ������Ĳ��ֿ׹ܹܶ�
%|---------------|  �׹�ֻ��ͼʾ�п�һ�ſף�����Ϊn
%|               |
%|����������������|
% lv ��������
% lc ���������ӹܳ�
% dp ���������ӹ�ֱ��
% la1 ���п׾���ǻ����ھ���
% la  �����֮��ľ���
% la2 ���п׾���ǻ����ھ���
% Din �׹ܹܾ�
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
a = nan;%����
isDamping = 1;%Ĭ��ʹ������
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%ʹ��ֱ�����۴��滺��ޣ���ô�����ʱ�൱������ֱ��ƴ��
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
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
        case 'mach' %����������������������ʹ�ô��������Ĺ�ʽ����
            mach = val;
        case 'm'
            mach = val;
        case 'notmach'
            notMach = val;
        case 'sigma'
            sigma = val;
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
% S = pi .* Din.^2 ./ 4;
% Sv = pi .* Dv.^2 ./ 4;
% % mfvVessel = nan;
% if ~isnan(meanFlowVelocity)
%     if 1 == length(meanFlowVelocity)
%         mfvVessel = meanFlowVelocity.*S./Sv;
%         meanFlowVelocity = [meanFlowVelocity,mfvVessel];
%     end
% else 
%     error(['��ָ�����٣������ǹܵ����뻺���ʱ�����٣�',...
%     '����Ҫָ����������٣�����ʹ��һ����������Ԫ�ص�����[pipe��vessel]']);
% end
% mfvVessel = meanFlowVelocity(2);
if isDamping
    if isnan(coeffDamping)
        if isnan(coeffFriction)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰coeffFriction���ܵ�Ħ��ϵ��');
        end
        if isnan(meanFlowVelocity)
            error('����Ҫ�������ᣬ��û�ж�������ϵ�����趨�塰meanFlowVelocity��ƽ������');
        end
        coeffDamping = (4.*coeffFriction.*meanFlowVelocity./Dpipe)./(2.*a);       
    end
end
if length(meanFlowVelocity) < 2
    if isnan(coeffDamping) < 2
        error('������ȫ������meanFlowVelocity����coeffDamping');
    end
end
if ~notMach%����ʹ������
    if isnan(mach)
        if ~isnan(meanFlowVelocity)
            mach = meanFlowVelocity./a;
        else
            error('��Ҫ�趨ƽ�����٣���ο�����:meanflowvelocity');
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
%���ﶼ����ֱ�ܵ�???
function M = haveMulHelsInletTransferMatrix(a,k,V,lv,lc,dp,la1,la2,la,Din,optDamping,optMach,sigma)
%�ڲ�׹ܿ�һ�п׵�ЧΪ�����ķ���ȹ������������ݾ���
%|�������������� |
%|   la1     la2|
%|--------- ----|  ��Ч��ķ���ȹ������Ĳ��ֿ׹ܹܶ�
%|--------- ----|  �׹�ֻ��ͼʾ�п�һ�пף�����Ϊn
%|              |
%|�������������� |
% lv ��������
% lc ���������ӹܳ�
% Dp ���������ӹ�ֱ�� dp*n 
% la1 ���п׾���ǻ����ھ���
% la2 ���п׾���ǻ����ھ���
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
            optDamping.coeffDamping = 0;%ע�⣬����ǻ���޵�ף��ϵ��
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
    %��??�侶�Ĵ��ݾ�???
%     Sv = pi.* Dv.^2 ./ 4;
%     Spipe = pi.* Dpipe.^2 ./ 4; 
    %innerPML = [1,0;0,1]; 
    %��ķ���ȹ��������ݾ�???
    HM = HelmholtzResonatorTransferMatrix_nInParallel(V,lv,lc,dp,'a',a,'k',k,'sigma',sigma);
    M = Mv2 * HM * Mv * HM * Mv * HM * Mv * HM * Mv1;%�ٶ���4����
end