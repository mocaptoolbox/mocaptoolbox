function mustBeMocapNormSegm(a)
    if ~any(strcmpi(a.type,{'MoCap data','norm data','segm data'}))
        eidType = 'MocapToolbox:mustBeMocapNormSegm';
        msgType = 'Input must be a MoCap, norm, or segm data structure';
        throw(MException(eidType,msgType))
    end
end
