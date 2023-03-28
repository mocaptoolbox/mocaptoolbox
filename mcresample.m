function d2 = mcresample(d, newfreq, method)
% Resamples motion capture data using interpolation.
%
% syntax
% d2 = mcresample(d, newfreq, method);
%
% input parameters
% d: MoCap structure
% newfreq: new frame rate
% method: interpolation method (optional, default 'linear'; for other options, see help interp1)
%
% output
% d2: MoCap structure
%
% examples
% d2 = mcresample(d, 240);
% d2 = mcresample(d, 360, 'spline');
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2 = [];

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end
if ~isnumeric(newfreq)
     disp([10, 'The second input argument has to be numeric.', 10]);
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     return
end


if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    if nargin==2
        method = 'linear';
    end
    d2 = d;
    data2 = resamp(d2.data,d2.freq,newfreq,method);
    if isfield(d,'other') & isfield(d.other,'quat') & ~isempty(d.other.quat)
        d2.other.quat = resamp(d.other.quat,d2.freq,newfreq,method);
    end
    d2.data = data2;
    d2.freq = newfreq;
    d2.nFrames = size(d2.data,1);

else
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
end
function d2 = resamp(d1,freq,newfreq,method)
    t1 = (0:(size(d1,1)-1))/freq;
    t2 = 0:(1/newfreq):t1(end);
    d2 = interp1(t1, d1, t2, method);
end
