function [pressure1,pressure2,pressure3,pressure4] = facvesselInBiasHaveInnerPerfBothClosedCompCalc(massFlowE,Frequency,time ...
    ,L1,L2,L3,L4,Dpipe,Dv,Dv1,Dv2,l,LV2_1,LV2_2,LV1,LV3,lc,dp1,dp2,lp1,lp2,n1,n2,la1,la2,lb1,lb2,Din,Dbias,LBias,xSection1,xSection2...
	,sectionL1,sectionL2,sectionL3,sectionL4,varargin)
%������м����׹�,���˶��������׸��������Ե�ЧΪ��ķ���ȹ�����,��������ƫ��
%                 L1
%                     |
%                     |
%           l   LBias |                                    L2  
%              _______|_________________________________        
%             |    dp(n1)            |    dp(n2)        |
%             |           ___ _ _ ___|___ _ _ ___ lc    |     
%             |          |___ _ _ ___ ___ _ _ ___|Din   |----------
%             |           la1 lp1 la2|lb1 lp2 lb2       |
%             |______________________|__________________|       
%                             Lin         Lout          l
%                       Lv1                  Lv2
%    Dpipe                       Dv                     Dpipe              
%
% Lin �ڲ�׹���ڶγ��� 
% Lout�ڲ�׹ܳ��ڶγ���
% lc  �׹ܱں�
% dp  �׹�ÿһ���׿׾�
% n1  �׹���ڶο��׸�����    n2  �׹ܳ��ڶο��׸���
% la1 �׹���ڶξ���ڳ��� 
% la2 �׹���ڶξ���峤��
% lb1 �׹ܳ��ڶξ���峤��
% lb2 �׹ܳ��ڶξ࿪�׳���
% lp1 �׹���ڶο��׳���
% lp2 �׹ܳ��ڶο��׳���
% Din �׹ܹܾ���
% xSection1��xSection2 �׹�ÿȦ�׵ļ�࣬��0��ʼ�㣬x�ĳ���Ϊ�׹ܿ׵�Ȧ��+1��x��ֵ�ǵ�ǰһȦ�׺���һȦ�׵ľ��룬������һ������ôx���ֵ��һ��

pp=varargin;
k = nan;
oumiga = nan;
a = 345;%����

isDamping = 1;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach
pressureBoundary2 = 0;%���㴫�ݾ����Ӧp2ֵ
isOpening = 1;
if 1 == size(pp,2)
%�����̬����ֻ��һ����˵���Ǹ��ṹ��
    st = pp{1};
    if ~isstruct(st)
        error('����varargin��Ҫһ��makeCommonTransferMatrixInputStruct�����Ľṹ��');
    end
    k = st.k;
    oumiga = st.oumiga;
    a = st.a;
    isDamping = st.isDamping;
    coeffDamping = st.coeffDamping;
    coeffFriction = st.coeffFriction;
    meanFlowVelocity = st.meanFlowVelocity;
    notMach = st.notMach;
    isOpening = st.isOpening;
    mach = st.mach;
else
    while length(pp)>=2
        prop =pp{1};
        val=pp{2};
        pp=pp(3:end);
        switch lower(prop)
            case 'a' %����
                a = val; 
            case 'acousticvelocity' %����
                a = val;
            case 'acoustic' %����
                a = val;
            case 'isdamping' %�Ƿ��������
                isDamping = val;   
            case 'friction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
                coeffFriction = val;
            case 'coefffriction' %�ܵ�Ħ��ϵ������������ϵ��ʱʹ��
                coeffFriction = val;
            case 'meanflowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
                meanFlowVelocity = val;
            case 'flowvelocity' %ƽ�����٣���������ϵ��ʱʹ��
                meanFlowVelocity = val;
            case 'mach' %����������������������ʹ�ô��������Ĺ�ʽ����
                mach = val;
            case 'coeffdamping'
                coeffDamping = val;
            case 'm'
                mach = val;
            case 'notmach' %ǿ���������������趨
                notMach = val;
            case 'k' %����
                k = val;
            case 'oumiga' %ԲƵ��
                oumiga = val;
            case 'isopening' %�ܵ�ĩ���Ƿ�Ϊ�޷����(����)�����Ϊ0������Ϊ�տڣ��������� �����ں�����pressureBoundary2ֵ��������P2�ı߽�����
                isOpening = val;
            case 'pressureboundary2' %���ڱ߽�������p2��ֵ��Ĭ��Ϊ0����������þ��൱����ȫ���ڣ�������Ա�����isOpening = 1��ʱ�����Ч
                pressureBoundary2 = val; 
            otherwise
                error('��������%s',prop);
        end
    end
end

if isnan(a)
    error('���ٱ��붨��');
end
% 
% L2
% Dpipe
% isDamping
% coeffFriction
% meanFlowVelocity
% mach
% notMach
% coeffDamping
% k
% oumiga




count = 1;
pressureE1 = [];
for i = 1:length(Frequency)
    f = Frequency(i);
    %��ĩ�˹ܵ�
    matrix_4{count} = straightPipeTransferMatrix(L4,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_v2{count} = vesselTransferMatrix(LV3,l,'f',f,'a',a,'D',Dpipe,'Dv',Dv2...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_3{count} = straightPipeTransferMatrix(L3,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_Mv{count} = vesselIBHaveInnerPerfBothClosedCompTransferMatrix(Dpipe,Dv,l,LV2_1,LV2_2...
        ,lc,dp1,dp2,lp1,lp2,n1,n2...
        ,la1,la2,lb1,lb2,Din...
        ,Dbias,LBias...
        ,xSection1,xSection2...
        ,'f',f,'a',a,'k',k,'oumiga',oumiga...
        ,'coeffDamping',coeffDamping,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'notmach',notMach...
        );
    matrix_2{count} = straightPipeTransferMatrix(L2,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_v1{count} = vesselTransferMatrix(LV1,l,'f',f,'a',a,'D',Dpipe,'Dv',Dv1...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_1{count} = straightPipeTransferMatrix(L1,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach,'coeffDamping',coeffDamping,'k',k,'oumiga',oumiga);
    matrix_total =matrix_4{count} * matrix_v2{count} * matrix_3{count} * matrix_Mv{count} * matrix_2{count} * matrix_v1{count} * matrix_1{count};
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
            matrix_Xl3_total = matrix_lx3 * matrix_Mv{count2} * matrix_2{count2} * matrix_v1{count2} * matrix_1{count2};
        
            pressureEi(count2) = matrix_Xl3_total(1,1)*pressureE1(count2) + matrix_Xl3_total(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end
        pressure3(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end

count = 1;
plus4 = [];
pressure4 = [];
if ~isempty(sectionL4)
    for len = sectionL4
        count2 = 1;
        pTemp = [];
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrix_lx4 = straightPipeTransferMatrix(len,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach);
            matrix_Xl4_total = matrix_lx4 * matrix_v2{count2} * matrix_3{count2} * matrix_Mv{count2} * matrix_2{count2} * matrix_v1{count2} * matrix_1{count2};
        
            pressureEi(count2) = matrix_Xl4_total(1,1)*pressureE1(count2) + matrix_Xl4_total(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end
        pressure4(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end
end