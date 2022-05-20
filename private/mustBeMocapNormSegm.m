function mustBeMocapNormSegm(a)
    if ~any(strcmpi(a.type,{'MoCap data','norm data','segm data'}))
        eidType = 'mustBeMocapNormSegm';
        msgType = 'Input must be a MoCap, norm, or segm data structure';
        throwAsCaller(MException(eidType,msgType))
    end
end
