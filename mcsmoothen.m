function d2 = mcsmoothen(d, f)
% Smoothens motion capture data using a Butterworth (fast) or a Savitzky-Golay FIR (accurate) smoothing filter.
%
% syntax
% d2 = mcsmoothen(d);
% d2 = mcsmoothen(d, filterparams);
% d2 = mcsmoothen(d, method);
% d2 = mcsmoothen(d, window);
%
% input parameters
% d: MoCap data structure or segm data structure
% f:
%   filterparams: order and cutoff frequency for Butterworth filter (optional, default [2, 0.2])
%   method: Butterworth filtering is default - if Savitzky-Golay filtering is to be used, use 'acc' as method argument
%   window: window length (optional, default = 7) for Savitzky-Golay FIR smoothing filter
%   (if input is scalar or a string, Savitzky-Golay filter is chosen - if input is vector, it is considered as parameters for Butterworth filter)
%
% output
% d2: MoCap data structure or segm data structure
%
% examples
% d2 = mcsmoothen(d); % Butterworth filter smoothing with default parameters
% d2 = mcsmoothen(d, [2 .1]); % second order Butterworth filter with 0.1 Hz cutoff frequency
% d2 = mcsmoothen(d, 'acc'); % Savitzky-Golay filter smoothing with default frame length
% d2 = mcsmoothen(d, 9); % Savitzky-Golay filter smoothing using a 9-frame window
%
% comments
% The default parameters for the Butterworth filter create a second-order zero-phase digital
% Butterworth filter with a cutoff frequency of 0.2 Hz times the Nyquist frequency
% (half the mocap frame rate – if the frame rate is 120, then the cuttoff frequency is 12 Hz).
% For information about the Savitzky-Golay filter, see help sgolayfilt.
%
% see also
% mctimeder
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];

if nargin==1
    order=2;
    cutoff=.2;
    s='';
end

if nargin==2
    if strcmp(f, 'acc')
        s = f;
        f = 7;
    elseif isscalar(f)
        s = 'acc';
    elseif isvector(f) && ~ischar(f)
        if f(1) ~= floor(f(1));
            disp([10, 'The order parameter must be an integer.', 10]);
            [y,fs] = audioread('mcsound.wav');
            sound(y,fs);
            return
        end
        if f(2)>=1 || f(2)<=0
            disp([10, 'The cutoff frequency must be within the interval of (0,1).', 10]);
            [y,fs] = audioread('mcsound.wav');
            sound(y,fs);
            return
        end
        order=f(1);
        cutoff=f(2);
        s='';
    else
        disp([10, 'Inconsistent input arguments.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end


d2=d;

if strcmp(s, 'acc') %accurate, Savitzky-Golay version
    d2 = mctimeder(d, 0, f, 'acc');

else %fast Butterworth version
    if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
        d2.data = butter_l(d.data, order, cutoff);

    elseif isfield(d,'type') && strcmp(d.type, 'segm data')
        d2.roottrans = butter_l(d.roottrans, order, cutoff);
        d2.rootrot.az = butter_l(d.rootrot.az, order, cutoff);
        d2.rootrot.el = butter_l(d.rootrot.el, order, cutoff);
        for k=1:length(d.segm)
            if ~isempty(d.segm(k).eucl) d2.segm(k).eucl = butter_l(d.segm(k).eucl, order, cutoff); end
            if ~isempty(d.segm(k).angle) d2.segm(k).angle = butter_l(d.segm(k).angle, order, cutoff); end
            if ~isempty(d.segm(k).quat) d2.segm(k).quat = butter_l(d.segm(k).quat, order, cutoff); end
        end
    else
        disp([10, 'The first input argument has to be a variable with MoCap, norm, or segm data structure.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
    end
end
return


function dat2=butter_l(d, order, cutoff)

d_filt=[];

d_mc=mcinitstruct('MoCap data', d, 100);
[mf mm mgrid]=mcmissing(d_mc);
if sum(mf)>0 %missing frames need to be filled for the filtering!
   d_mc=mcfillgaps(d_mc);
   d=d_mc.data;
end


[b a]=butter(order, cutoff); %filtering

for k=1:size(d,2)
    dat=filtfilt(b,a,d(:,k));
    d_filt=[d_filt, dat];
end


if sum(mf)>0 %missing frames set back to NaN
    tmp=1:d_mc.nMarkers;
    tmp=[tmp;tmp;tmp];
    tmp=reshape(tmp,1,[]);
    mgrid=[mgrid(:,tmp)];
    d_filt(mgrid==1)=NaN;
end

dat2=d_filt;
