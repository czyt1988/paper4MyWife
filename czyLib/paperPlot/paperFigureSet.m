% ����ͼƬ�ߴ�ͳһ���ã���ȫ��
function paperFigureSet(wType,h)
    if 0 == nargin
        wType = 'normal';
        h = 6;
    elseif 1 == nargin
        h = 6;
    end
    switch lower(wType)
    case 'small'
        paperFigureSet_small(h);
    case 'normal'
        paperFigureSet_normal(h);
    case 'large'
        paperFigureSet_large(h);
    case 'full'
        paperFigureSet_FullWidth(h);
    case 'fullwidth'
        paperFigureSet_FullWidth(h);
    otherwise
        paperFigureSet_normal(h);
    end

end