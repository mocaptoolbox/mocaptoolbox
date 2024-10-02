function mustNotBePos(a)
    if a.timederOrder == 0
        eidType = 'MocapToolbox:mustNotBePos';
        msgType = 'Input cannot be position data. Use mctimeder() for conversion to velocity data.';
        throw(MException(eidType,msgType))
    end
end
