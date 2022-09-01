function s = mcskewness(d)
% Calculates the skewness of data, ignoring missing values.
%
% syntax
% m = mcskewness(d);
%
% input parameters
% d: Mocap data structure, norm data structure, or data matrix
%
% output
% m: row vector containing the skewness values of each data column
%
% see also
% mcmean, mcstd, mcvar, mckurtosis
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if isfield(d, 'data')
    for k=1:size(d.data,2)
        s(k) = skew(d.data(find(isfinite(d.data(:,k))),k));
    end
else
    for k=1:size(d,2)
        s(k) = skew(d(find(isfinite(d(:,k))),k));
    end
end

return

function sk = skew(y)

sk = sum((y-mean(y)).^3) / ((length(y)-1)*(std(y)).^3);

return
