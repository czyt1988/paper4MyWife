function pressure = straightPipePulsationCalc( massFlowE,Frequency,time,L...
    ,sectionL,varargin)
%����ֱ����������
% massFlowE��������Ҷ�任�����������,������fft�������з�ֵ����
% Frequency ������Ӧ��Ƶ�ʣ��˳����Ƕ�ӦmassFlowE��һ��
% L �ܳ�
% sectionL �ܵ������ֶΣ����ֵ���ܳ���L
%  opt �������ã����������
    pp=varargin;
    dynViscosity = nan;
    density = nan;
    calcWay2 = 0;
    k = nan;
    oumiga = nan;
    f = nan;
    a = nan;%����
    S = nan;
    Dpipe = nan;
    isDamping = 0;
    coeffFriction = nan;
    meanFlowVelocity = nan;
    mach = nan;
    notMach = 0;%ǿ�Ʋ�ʹ��mach
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
        Dpipe = st.D;
    else
        while length(pp)>=2
            prop =pp{1};
            val=pp{2};
            pp=pp(3:end);
            switch lower(prop)
                case 's' %����
                    S = val;
                case 'd' %�ܵ�ֱ��
                    Dpipe = val;
                    S = (pi.*Dpipe^2)./4;
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
                case 'm'
                    mach = val;
                case 'notmach' %ǿ���������������趨
                    notMach = val;
                case 'isopening'%�ܵ�ĩ���Ƿ�Ϊ�޷����(����)�����Ϊ0������Ϊ�տڣ���������
                    isOpening = val;
                case 'calcway2'
                    calcWay2 = val;
                case 'dynvis'%����ѧճ��pa-s
                    dynViscosity = val;
                case 'dynviscosity'%����ѧճ��pa-s
                    dynViscosity = val;
                case 'density'%�ܶ�
                    density = val;    
                otherwise
                    error('��������%s',prop);
            end
        end
    end



    count = 1;
    pressureE1 = [];
    for i = 1:length(Frequency)
        f = Frequency(i);
        matrix_total = straightPipeTransferMatrix(L,'s',S,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach...
            ,'calcWay2',calcWay2,'density',density,'dynViscosity',dynViscosity);
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
    %% ���ݳ�ʼ������ѹ���������������ѹ��

    count = 1;
    for len = sectionL
        count2 = 1;
        pressureEi = [];
        for i = 1:length(Frequency)
            f = Frequency(i);
            matrixTOther = straightPipeTransferMatrix(len,'s',S,'f',f,'a',a,'D',Dpipe...
            ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
            ,'m',mach,'notmach',notMach...
            ,'calcWay2',calcWay2,'density',density,'dynViscosity',dynViscosity);
            pressureEi(count2) = matrixTOther(1,1)*pressureE1(count2) + matrixTOther(1,2)*massFlowE(count2);
            count2 = count2 + 1;
        end
        pressure(:,count) = changToWave(pressureEi,Frequency,time);
        count = count + 1;
    end
end
