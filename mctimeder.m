function d2 = mctimeder(d, n, f, s)
% Estimates time derivatives of motion capture data. Two options are available, the fast version
% uses differences between two successive frames and a Butterworth smoothing filter,
% whereas the accurate version uses derivation with a Savitzky-Golay FIR smoothing filter.
%
% syntax
% d2 = mctimeder(d);
% d2 = mctimeder(d, n);
% d2 = mctimeder(d, filterparams);
% d2 = mctimeder(d, s);
% d2 = mctimeder(d, n, filterparams);
% d2 = mctimeder(d, n, s);
% d2 = mctimeder(d, n, window, s);
%
% input parameters
% d: MoCap structure, norm structure, or segm structure
% n: order of time derivative (optional, default = 1).
% f:
%   filterparams: order and cutoff frequency for Butterworth smoothing filter (optional, default [2, 0.2])
%   window: window length for Savitzky-Golay FIR smoothing filter (optional, default = 7 for first-order derivative)
% s: fast or accurate version; fast version is default, use 'acc' for accurate version (if no window length is given, the default lengths are used, see comment)%
%
% output
% d2: MoCap structure, norm structure, or segm structure
%
% examples
% d2 = mctimeder(d) % first-order time derivative using the fast version
% d2 = mctimeder(d, [2 .1]); % first-order time derivative using fast version (second order Butterworth
% filter with 0.1 cutoff – see comments)
% d2 = mctimeder(d, 'acc'); % first-order time derivative using the accurate
% version (Savitzky-Golay filter)
% d2 = mctimeder(d, 2, 9, 'acc'); % second-order time derivative with 9-frame
% window using the accurate version (Savitzky-Golay filter)
%
% comments
% The default parameters for the Butterworth smoothing filter create a second-order zero-phase digital
% Butterworth filter with a cutoff frequency of 0.2 times the Nyquist frequency
% (half the mocap frame rate – if the frame rate is 120, then the cuttoff frequency is 12 Hz).
% The window length is dependent on the order of the time derivative and the
% given window length. It is calculated by 4*n+w-4. Thus, if the default
% window length of 7 is used, the window length for the second-order derivative
% will be 11, and the window length for the third-order derivative will be 15.
% For information about the Savitzky-Golay filter, see help sgolayfilt.
% The function updates the d.timederorder field as follows: d2.timederorder = d.timederorder + order.
%
% see also
% mcsmoothen, mctimeintegr
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland


d2=[];

if nargin==1
    n = 1;
    order = 2;
    cutoff = .2;
    s = '';
end

if nargin==2
    if isscalar(n)
        order = 2;
        cutoff = .2;
        s = '';
    elseif isvector(n) && ~ischar(n)
        order = n(1);
        cutoff = n(2);
        n = 1;
        s = '';
    elseif strcmp(n, 'acc')
        s = n;
        n = 1;
        f = 7;
    else
        disp([10, 'Inconsistent input arguments.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

if nargin==3
    if ischar(f)
        s = f;
        f = 7;
    elseif isvector(f) && ~ischar(f)
        order = f(1);
        cutoff = f(2);
        s = '';
    else
        disp([10, 'Inconsistent input arguments.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end




if strcmp(s,'acc') %accurate version
    if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
        % differentiate MoCap data
        d2 = d;
        d2.data = differentiate(d.data, n, f) * d.freq^n;
        d2.timederOrder = d.timederOrder + n;
    elseif isfield(d,'type') && strcmp(d.type, 'segm data')
        % differentiate segm data
        d2 = d;
        d2.roottrans = differentiate(d.roottrans, n, f) * d.freq^n;
        d2.rootrot.az = differentiate(d.rootrot.az, n, f) * d.freq^n;
        d2.rootrot.el = differentiate(d.rootrot.el, n, f) * d.freq^n;
        for k=1:length(d.segm)
            if ~isempty(d.segm(k).eucl) d2.segm(k).eucl = differentiate(d.segm(k).eucl, n, f) * d.freq^n; end
            if ~isempty(d.segm(k).angle) d2.segm(k).angle = differentiate(d.segm(k).angle, n, f) * d.freq^n; end
            if ~isempty(d.segm(k).quat) d2.segm(k).quat = differentiate(d.segm(k).quat, n, f) * d.freq^n; end
        end
        d2.timederOrder = d.timederOrder + n;
    else
        disp([10, 'This function only works with MoCap, norm, or segment data structures.',10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
    end

else %fast version - default option
    if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
        % differentiate_fast MoCap data

        %check for empty markers and set to 0 - BBFIX 20220329
        mf1=mcmissing(d);
        for k=1:length(mf1)
            if mf1(k)==d.nFrames
                d.data(:,k*3-2)=0;
                d.data(:,k*3-1)=0;
                d.data(:,k*3)=0;
            end
        end

        d2 = d;
        d2.data = differentiate_fast(d.data, n, order, cutoff) * d.freq^n;
        d2.timederOrder = d.timederOrder + n;

        %restore empty markers and set to NaN - BBFIX 20220329
        for k=1:length(mf1)
            if mf1(k)==d.nFrames
                d2.data(:,k*3-2)=NaN;
                d2.data(:,k*3-1)=NaN;
                d2.data(:,k*3)=NaN;
            end
        end

    elseif isfield(d,'type') && strcmp(d.type, 'segm data')
        % differentiate_fast segm data
        d2 = d;
        d2.roottrans = differentiate_fast(d.roottrans, n, order, cutoff) * d.freq^n;
        d2.rootrot.az = differentiate_fast(d.rootrot.az, n, order, cutoff) * d.freq^n;
        d2.rootrot.el = differentiate_fast(d.rootrot.el, n, order, cutoff) * d.freq^n;
        for k=1:length(d.segm)
            if ~isempty(d.segm(k).eucl) d2.segm(k).eucl = differentiate_fast(d.segm(k).eucl, n, order, cutoff) * d.freq^n; end
            if ~isempty(d.segm(k).angle) d2.segm(k).angle = differentiate_fast(d.segm(k).angle, n, order, cutoff) * d.freq^n; end
            if ~isempty(d.segm(k).quat) d2.segm(k).quat = differentiate_fast(d.segm(k).quat, n, order, cutoff) * d.freq^n; end
        end
        d2.timederOrder = d.timederOrder + n;
    else
        disp([10, 'This function only works with MoCap, norm, or segment data structures.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
    end
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function der = differentiate(d, n, f)



pol = n+1; % polynomial order %BBFIX 20110207: pol now dependent on the order of derivative

f = 4*n+f-4; %%BBFIX 20110207: increase window size relative to the order of derivative

tmp = [];

fprintf('Calculating');
for k=1:size(d,2)
    fprintf('.');
    tmp = [tmp smoothderiv(d(:,k),pol,f,n)'];
end
fprintf('\n');

tmp = tmp(((f+1)/2):end,:);
der = [repmat(tmp(1,:),(f-1)/2,1); tmp; repmat(tmp(end,:),(f+1)/2,1)]; % make size(tmp) = size(d.data)

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function der = differentiate_fast(d, n, order, cutoff) %%ADD 20110908: fast version


[b,a]=butter(order, cutoff); % optimal filtering frequency is 0.2 Nyquist frequency

d_mc=mcinitstruct('MoCap data', d, 100);
[mf mm mgrid]=mcmissing(d_mc);
if sum(mf)>0 %missing frames need to be filled for the filtering!
   d_mc=mcfillgaps(d_mc,'fillall');%BB FIX 20111212, also beginning and end need filling
   d=d_mc.data;
end

for k=1:n %differences and filtering
    d=diff(d);
    d=filtfilt(b,a,d);
    d = [repmat(d(1,:),1,1); d];
end

if sum(mf)>0 %missing frames set back to NaN
    tmp=1:d_mc.nMarkers;
    tmp=[tmp;tmp;tmp];
    tmp=reshape(tmp,1,[]);
    mgrid=[mgrid(:,tmp)];
    d(mgrid==1)=NaN;
end

der = d;

return
