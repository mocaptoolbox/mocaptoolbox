function s = mckurtosis(d)
% Calculates the kurtosis of data, ignoring missing values.
%
% syntax
% m = mckurtosis(d);
%
% input parameters
% d: Mocap data strcuture, norm data structure, or data matrix.
%
% output
% m: row vector containing the kurtosis values of each data column
%
% see also
% mcmean, mcstd, mcvar, mcskewness
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if isfield(d, 'data')
    for k=1:size(d.data,2)
        s(k) = kurt(d.data(find(isfinite(d.data(:,k))),k));
    end
else
    for k=1:size(d,2)
        s(k) = kurt(d(find(isfinite(d(:,k))),k));
    end
end

return

function ku = kurt(y)

    N=length(y);
    tmp=y-mean(y);
    m2 = sum(tmp.^2);
    m4 = sum(tmp.^4);
    ku = m4/(N*(std(tmp)^4))-3;

return
