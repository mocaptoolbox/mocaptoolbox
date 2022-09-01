function [per, ac, eac, lag] = mcperiod(d, maxper, method)
% Estimates the period of movement for each marker and each dimension.
%
% syntax
% [per, ac, eac, lag] = mcperiod(d);
% [per, ac, eac, lag] = mcperiod(d, maxper);
% [per, ac, eac, lag] = mcperiod(d, method);
% [per, ac, eac, lag] = mcperiod(d, maxper, method);
%
% input parameters
% d: MoCap or norm data structure
% maxper: maximal period in seconds (optional, default = 2 secs)
% method: sets if 'first' or 'highest' maximal value of the autocorrelation
%   function is taken as periodicity estimation (optional, default: 'first')
%
% output
% per: row vector containing period estimates for each column
% ac: matrix containing autocorrelation functions for each column
% eac: matrix containing enhanced autocorrelation functions for each column
% lag: vector containing lag values for the (normal and enhanced) autocorrelation functions
%
% examples
% [per, ac, eac, lag] = mcperiod(d, 3);
% per = mcperiod(d, 'highest');
%
% comments
% In ac and eac, each column corresponds to a dimension of a marker
% (or in case of norm data to a marker), and each row corresponds to a time lag.
%
% references
% Eerola, T., Luck, G., & Toiviainen, P. (2006). An investigation of pre-schoolers'
% corporeal synchronization with music. Paper presented at the 9th International
% Conference on Music Perception and Cognition, Bologna, Italy.
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland


per = []; ac=[]; eac=[]; lag=[];

if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    if nargin == 1
        maxper = 2;
        method = 'first';
    end
    if nargin == 2  %adapted BB20101202
        if isletter(maxper)
            method=maxper;
            maxper=2;
        else
            method = 'first';
        end
    end

    d.data = detrend(d.data);
    maxlag = round(maxper*d.freq);
    lagfr = (0:maxlag)';
    lag = lagfr / d.freq;
    for m=1:size(d.data,2)
        tmp = d.data(:,m);
        tmp = tmp - mean(tmp);
        tmp2 = xcorr(tmp, maxlag);
        tmp2 = tmp2((maxlag+1):end);
        ac = [ac tmp2]; % autocorrelation function
% calculate period
        tmp2 = tmp2 / max(tmp2); % normalize
        ind = find(diff(sign(diff(tmp2)))==-2); % find local maxima %PTBB FIX 20130211
        if isempty(ind)
            per(m) = NaN;
        else
            if strcmp(method, 'highest')
                w = min(ind); %highest peak
                [qq,ww] = max(tmp2(w:end));
                maci = w+ww-1;
            elseif strcmp(method, 'first')
                maci=min(ind)+1;%first peak %PTBB FIX 20130211
            else disp([10, 'Argument for "method" unknown.', 10]);
                [y,fs] = audioread('mcsound.wav');
                sound(y,fs);
                return
            end
            if maci==1
                per(m)=NaN;
            elseif maci==length(tmp2)
                per(m)=NaN;
            else
                fraction=-(tmp2(maci+1)-tmp2(maci-1))/(tmp2(maci-1)+tmp2(maci+1)-2*tmp2(maci));
                per(m) = (maci-1+fraction)/d.freq;
            end
        end
% calculate enhanced autocorrelation
        tmp3 = max(tmp2, 0);
        tmp4 = tmp3 - interp1(lagfr, tmp3, lagfr/2);
        eac = [eac max(tmp4,0)]; % enhanced autocorrelation function
    end
else
    disp([10, 'The first input argument should be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
