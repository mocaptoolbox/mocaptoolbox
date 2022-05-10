function mom = mcstatmoments(d)
% Calculates the first four statistical moments (mean, standard deviation, skewness, and kurtosis) of data, ignoring missing values.
%
% syntax
% mom = mcstatmoments(d);
%
% input parameters
% d: Mocap data structure, norm data structure, or data matrix.
%
% output
% mom: structure containing the fields .mean, .std, .skewness, and .kurtosis
% 
% comments
% Calls the functions mcmean, mcstd, mcskewness, and mckurtosis
%
% see also
% mcmean, mcstd, mcskewness, mckurtosis
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland




mom.mean = mcmean(d);
mom.std = mcstd(d);
mom.skewness = mcskewness(d);
mom.kurtosis = mckurtosis(d);
