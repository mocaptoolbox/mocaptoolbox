function m = mcmean(d)
% Calculates the temporal mean of data, ignoring missing values.
%
% syntax
% m = mcmean(d);
%
% input parameters
% d: Mocap data structure, norm data structure, or data matrix.
%
% output
% m: row vector containing the means of each data column
%
% see also
% mcstd, mcvar, mcskewness, mckurtosis
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

if isfield(d, 'data')
    for k=1:size(d.data,2)
        m(k) = mean(d.data(find(isfinite(d.data(:,k))),k));
    end
else
    for k=1:size(d,2)
        m(k) = mean(d(find(isfinite(d(:,k))),k));
    end
end
