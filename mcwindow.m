function varargout = mcwindow(functionhandle, d, wlen, hop, timetype)
% Performs a windowed time series analysis with a given function.
%
% syntax
% varargout = mcwindow(functionhandle, d);
% varargout = mcwindow(functionhandle, d, wlen, hop);
% varargout = mcwindow(functionhandle, d, wlen, hop, timetype);
%
% input parameters
% functionhandle: handle to function with which the windowed analysis is performed
% d: Mocap data structure or norm data structure
% wlen: length of window (optional, default = 2 sec)
% hop: hop factor (optional, default = 0.5)
% timetype: time type {'sec', 'frame'} (optional, default = 'sec')
%
% output
% When used with the functions mcmean, mcstd, mcvar, mcskewness, and mckurtosis, the output 
% is a two-dimensional matrix where the first index corresponds to window 
% number and the second index to marker/dimension.
% When used with mcperiod, the function returns four output parameters 
% [per, ac, eac, lag], where per is a two-dimensional matrix with the first 
% index corresponding to window number and the second to marker/dimension. 
% Output parameters ac and eac are three-dimensional matrices, with the first 
% index corresponding to window number, the second to lag, and the third to marker/dimension.
% The output parameter lag is a vector containing the lag values for the
% autocorrelations.
%
% examples
% stds = mcwindow(@mcstd, d, 3, 0.5);
% [per, ac, eac, lags] = mcwindow(@mcperiod, d);
%
% see also
% mcmean, mcstd, mcvar, mcskewness, mckurtosis, mcperiod
% 
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

for k=1:nargout
    varargout(k)={[]};
end
    
% initialize
fn = func2str(functionhandle); % get function name
if strcmp(fn,'mcmean') || strcmp(fn,'mcstd') || strcmp(fn,'mcvar') || strcmp(fn,'mcskewness') || strcmp(fn,'mckurtosis') %%BB20111017: extension with mcvar
    out1 = [];
elseif strcmp(fn, 'mcperiod')
    pers = [];
    acs = [];
    eacs = [];
else
    disp([10, 'Function handle unknown.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if nargin>=3 && ~isnumeric(wlen)
    disp([10, 'The third argument has to be numeric.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end
if nargin>=4 && ~isnumeric(hop)
    disp([10, 'The fourth argument has to be numeric.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if nargin==5 && ~strcmp(timetype, 'sec') && ~strcmp(timetype, 'frame')
    disp([10, 'The fifth argument has to be a string ("sec" or "frame").', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end


if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    if nargin<5 
        timetype='sec'; 
    end
    if nargin<=3
        wlen=2; 
        hop=0.5;
    end
    if strcmp(timetype, 'sec')
        wlen=round(wlen*d.freq);
    end

    wstep=round(hop*wlen);
    wstart = (0:wstep:size(d.data,1)-wlen) / d.freq; % start times of windows in secs

    for k=1:wstep:size(d.data,1)-wlen+1
        if strcmp(fn,'mcmean') || strcmp(fn,'mcvar') || strcmp(fn,'mcstd') || strcmp(fn,'mcskewness') || strcmp(fn,'mckurtosis')
            out1 = [out1; functionhandle(mctrim(d, k, k+wlen-1, 'frame'))];
        elseif strcmp(fn, 'mcperiod')            
            [per, ac, eac, lag] = functionhandle(mctrim(d, k, k+wlen-1, 'frame'));
            pers = [pers; per];
            acs = [acs; ac];
            eacs = [eacs; eac];
            lags =lag;
        end
    end
else
    disp([10, 'The first input argument should be a variable with MoCap data or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if strcmp(fn,'mcmean') || strcmp(fn,'mcstd') || strcmp(fn,'mcvar') || strcmp(fn,'mcskewness') || strcmp(fn,'mckurtosis')
    varargout(1) = {out1};
    varargout(2) = {wstart};
elseif strcmp(fn, 'mcperiod')
    varargout(1) = {pers};
    varargout(2) = {shiftdim(reshape(acs',size(ac,2),size(ac,1),size(acs,1)/size(ac,1)),1)};
    varargout(3) = {shiftdim(reshape(eacs',size(ac,2),size(ac,1),size(acs,1)/size(ac,1)),1)};
    varargout(4) = {lags};
    varargout(5) = {wstart};
end