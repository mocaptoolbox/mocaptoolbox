function [s, f] = mcspectrum(d)
% Calculates the amplitude spectrum of mocap time series.
%
% syntax
% s = mcspectrum(d);
% [s, f] = mcspectrum(d)
%
% input parameters
% d: MoCap structure, norm structure, or segm structure
%
% output
% s: MoCap structure, norm structure, or segm structure containing
% amplitude spectra in the .data field
% f: frequencies in Hz for the frequency channels in the spectra
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

s=[];
f=[];


if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    f = ((1:d.nFrames)-1)*d.freq / d.nFrames;
    s = d;
    d.data=d.data-repmat(mean(d.data),d.nFrames,1);
    s.data = abs(fft(d.data));
elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    f = ((1:d.nFrames)-1)*d.freq / d.nFrames;
    % differentiate segm data
    s = d;
    d.roottrans=d.roottrans-repmat(mean(d.roottrans),d.nFrames,1);
    s.roottrans = abs(fft(d.roottrans));
    d.rootrot.az=d.rootrot.az-repmat(mean(d.rootrot.az),d.nFrames,1);
    s.rootrot.az = abs(fft(d.rootrot.az));
    d.rootrot.el=d.rootrot.el-repmat(mean(d.rootrot.el),d.nFrames,1);
    s.rootrot.el = abs(fft(d.rootrot.el));
    for k=1:length(d.segm)
        if ~isempty(d.segm(k).eucl)
            d.segm(k).eucl=d.segm(k).eucl-repmat(mean(d.segm(k).eucl),d.nFrames,1);
            s.segm(k).eucl = abs(fft(d.segm(k).eucl));
        end
        if ~isempty(d.segm(k).angle)
            d.segm(k).angle=d.segm(k).angle-repmat(mean(d.segm(k).angle),d.nFrames,1);
            s.segm(k).angle = abs(fft(d.segm(k).angle));
        end
        if ~isempty(d.segm(k).quat)
            d.segm(k).quat=d.segm(k).quat-repmat(mean(d.segm(k).quat),d.nFrames,1);
            s.segm(k).quat = abs(fft(d.segm(k).quat));
        end
    end
else
    disp([10, 'The first input argument has to be a variable with MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end

return

