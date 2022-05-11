function d2 = mcbandpass(d, f1, f2, method)
% Band pass filters data in a MoCap or norm structure using an FFT filter.
%
% syntax
% d2 = mcbandpass(d, f1, f2);
% d2 = mcbandpass(d, f1, f2, method);
%
% input parameters
% d: MoCap or norm data structure
% f1: lower frequency of passband
% f2: higher frequency of passband
% method: filtering window, 'rect' (default) or 'gauss'
%
% output
% d2: MoCap or norm data structure containing band bass filtered data
%
% examples
% d2 = mcbandpass(d, 0.5, 2);
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

if nargin<4 
    method='rect'; 
end

d2=[];

if nargin<3
    disp([10, 'Please enter a mocap data or norm structure and the passband frequencies.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if ~isnumeric(f1) || ~isnumeric(f2) || length(f1)>1 || length(f2)>1
    disp([10, 'Frequency arguments have to be single numerics.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if length(d)>1
    for k=1:length(d) 
        d2(k) = mcbandpass(d(k), f1, f2, method); 
    end
else
    if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
        d2=d;
        m = mean(d.data); d.data = d.data - repmat(m,size(d.data,1),1);
        d2.data = fftfilter(d.data, d.freq, f1, f2, method);
        d2.data = d2.data + repmat(m,size(d2.data,1),1);
    elseif isfield(d,'type') && strcmp(d.type, 'segm data')
        d2 = d;
        m=mean(d.roottrans); d.roottrans = d.roottrans - repmat(m,d.nFrames,1);
        d2.roottrans = fftfilter(d.roottrans,d.freq,f1,f2, method); d2.roottrans=d2.roottrans+repmat(m,d.nFrames,1);
        m=mean(d.rootrot.az); d.rootrot.az = d.rootrot.az - repmat(m,d.nFrames,1);
        d2.rootrot.az = fftfilter(d.rootrot.az,d.freq,f1,f2, method); d2.rootrot.az=d2.rootrot.az+repmat(m,d.nFrames,1);
        m=mean(d.rootrot.el); d.rootrot.el = d.rootrot.el - repmat(m,d.nFrames,1);
        d2.rootrot.el = fftfilter(d.rootrot.el,d.freq,f1,f2, method); d2.rootrot.el=d2.rootrot.el+repmat(m,d.nFrames,1);
        for m=1:length(d.segm)
            if ~isempty(d.segm(m).eucl)
                me=mean(d.segm(m).eucl); d.segm(m).eucl = d.segm(m).eucl - repmat(me,d.nFrames,1);
                d2.segm(m).eucl = fftfilter(d.segm(m).eucl,d.freq,f1,f2, method); d2.segm(m).eucl=d2.segm(m).eucl+repmat(me,d.nFrames,1);
            end
            if ~isempty(d.segm(m).angle)
                me=mean(d.segm(m).angle); d.segm(m).angle = d.segm(m).angle - repmat(me,d.nFrames,1);
                d2.segm(m).angle = fftfilter(d.segm(m).angle,d.freq,f1,f2, method); d2.segm(m).angle=d2.segm(m).angle+repmat(me,d.nFrames,1);
            end
            if ~isempty(d.segm(m).quat)
                me=mean(d.segm(m).quat); d.segm(m).quat = d.segm(m).quat - repmat(me,d.nFrames,1);
                d2.segm(m).quat = fftfilter(d.segm(m).quat,d.freq,f1,f2, method); d2.segm(m).quat=d2.segm(m).quat+repmat(me,d.nFrames,1);
            end
        end
    else
        disp([10, 'The first input argument have to be a variable with MoCap or norm data structure.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
    end
end
return;

%%%

function y2 = fftfilter(y, fs, minf, maxf, method)
% function y2 = fftfilter(y, fs, minf, maxf, method);
% non-causal bandpass filter based on fft

if nargin<5 method='rect'; end

y2 = y;
for k=1:size(y,2)
    z = fft(y(:,k));
    ff = (0:(length(z)-1)) / length(z);
    f = fs * (ff-round(ff));
    if strcmp(method,'gauss')
        meanf=0.5*(maxf+minf); 
        sd=0.5*(maxf-minf);
        sc = gauss(abs(f), meanf, sd)'; % scaling factor
        z = z.*sc;
    else
        ind = find(abs(f)<minf | abs(f)>maxf); % frequencies to be removed
        z(ind) = 0;
    end
    y2(:,k) = real(ifft(z)); % theoretically ifft(z) should be real, but real() is applied to remove rounding errors
end
return

function y = gauss(x, mu, var)
y=(1/(var*sqrt(2*pi)))*exp(-((x-mu).*(x-mu))/(2*var*var));
return



