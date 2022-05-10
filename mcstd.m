function s = mcstd(d)
% Calculates the temporal standard deviation of data, ignoring missing values.
%
% syntax
% m = mcstd(d);
%
% input parameters
% d: Mocap data structure, norm data structure, or data matrix.
%
% output
% m: row vector containing the standard deviations of each data column
% 
% see also
% mcmean, mcvar, mcskewness, mckurtosis
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

if isfield(d, 'data')
    for k=1:size(d.data,2)
        s(k) = std(d.data(find(isfinite(d.data(:,k))),k));
    end
else
    for k=1:size(d,2)
        s(k) = std(d(find(isfinite(d(:,k))),k));
    end
end
