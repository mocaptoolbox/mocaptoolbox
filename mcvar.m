function s = mcvar(d)
% Calculates the temporal variance of data, ignoring missing values.
%
% syntax
% m = mcvar(d);
%
% input parameters
% d: Mocap data structure, norm data structure, or data matrix.
%
% output
% m: row vector containing the variances of each data column
%
% see also
% mcmean, mcstd, mcskewness, mckurtosis
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if isfield(d, 'data')
    for k=1:size(d.data,2)
        s(k) = var(d.data(find(isfinite(d.data(:,k))),k));
    end
else
    for k=1:size(d,2)
        s(k) = var(d(find(isfinite(d(:,k))),k));
    end
end
