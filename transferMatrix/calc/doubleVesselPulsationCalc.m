function [pressure1,pressure2,pressure3] = doubleVesselPulsationCalc( massFlowE,Frequency,time ...
    ,L1,L2,L3,Lv1,Lv2,l,Dpipe,Dv1,Dv2...
    ,sectionL1,sectionL2,sectionL3,varargin)
%������ݹ��ݵ�����
%   massFlowE1 ����fft�������������ֱ�Ӷ�������������ȥֱ��fft
%  ���� L1     l    Lv1   l   L2  l    Lv2   l     L3
%              __________         __________
%             |          |       |          |
%  -----------|          |-------|          |-------------
%             |__________|       |__________|  
%  ֱ�� Dpipe       Dv1    Dpipe       Dv2          Dpipe
%   
% massFlowE��������Ҷ�任�����������,������fft�������з�ֵ����
% Frequency ������Ӧ��Ƶ�ʣ��˳����Ƕ�ӦmassFlowE��һ��
% L �ܳ�
% sectionL �ܵ������ֶΣ����ֵ���ܳ���L
%  opt �������ã����������
% if 0==L2
% L1,L2,L3,Lv1,Lv2,l,Dpipe,Dv1,Dv2,sectionL1,sectionL2,sectionL3,varargin
% end

pp=varargin;
k = nan;
oumiga = nan;
a = 345;%����
% S = nan;
% Sv = nan;


isDamping = 0;
isOpening = 1;
coeffDamping = nan;
coeffFriction = nan;
meanFlowVelocity = nan;
isUseStaightPipe = 1;%ʹ��ֱ�����۴��滺��ޣ���ô�����ʱ�൱������ֱ��ƴ��
mach = nan;
notMach = 0;%ǿ�Ʋ�ʹ��mach

while length(pp)>=2
    prop =pp{1};
    val=pp{2};
    pp=pp(3:end);
    switch lower(prop)
            
        % case 'sv' %h����޽���
        %     Sv = val;
        % case 'dv' %h����޽���
        %     Dvessel = val;
            
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
        case 'isusestaightpipe'
            isUseStaightPipe = val;%ʹ��ֱ���������
        case 'usestaightpipe'
            isUseStaightPipe = val;
        case 'm'
            mach = val;
        case 'isopening'
            isOpening = val;
        case 'notmach' %ǿ���������������趨
            notMach = val;
        otherwise
            error('��������%s',prop);
    end
end
%����û�û�ж���k��ô��Ҫ�����������м���
% S = (pi.*Dpipe^2)./4;
% Sv1 = (pi.*Dv1.^2)./4;
% Sv2 = (pi.*Dv2.^2)./4;
if isnan(a)
    error('���ٱ��붨��');
end

count = 1;
pressureE1 = [];
for i = 1:length(Frequency)
    f = Frequency(i);

    [matrix_3{count},~,coeffDamping] = straightPipeTransferMatrix(L3,'f',f,'a',a,'D',Dpipe...
        ,'isDamping',isDamping,'coeffFriction',coeffFriction,'meanFlowVelocity',meanFlowVelocity...
        ,'m',mach,'notmach',notMach);

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
        pressureE1(count) = ((-B/A)*massFlowE(count));
    else
        pressureE1(count) = ((-D/C)*massFlowE(count));
    end
    count = count + 1;
end
%% ���ݴ��ݾ�������ʼ������ѹ��
%% ���ݳ�ʼ������ѹ���������������ѹ��

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
