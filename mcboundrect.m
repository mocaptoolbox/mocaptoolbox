function br = mcboundrect(d, mnum, w, hop)
% Calculates the bounding rectangle (the smallest rectangular area that contains the
% projection of the trajectory of each marker on the horizontal plane (i.e., floor).
%
% syntax
% br = mcboundrect(d);
% br = mcboundrect(d, mnum);
% br = mcboundrect(d, mnum, w, hop);
%
% input parameters
% d: MoCap data structure
% mnum: marker numbers (optional; if no value given, all markers are used)
% w: length of analysis window (optional; default: 4 sec)
% hop: overlap of analysis windows (optional; default: 2 sec)
%
% output
% br: data matrix (windows x nMarkers)
%
% examples
% br = mcboundrect(d);
% br = mcboundrect(d, [1 3 5]);
% br = mcboundrect(d, [1:d.nMarkers], 3, 1);
%
% comments
% If the function is called with the mocap data structure as the only input
% parameter, the calculation is performed for all markers with the default
% parameters. If the window and overlap length are to be changed, the
% markers have to be always specified (e.g., all markers by [1:d.nMarkers]).
%
% see also
% mcboundvol
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

br=[];

if nargin==1
    w=4;
    hop=2;
end

if nargin>1
    if ~isnumeric(mnum)
        disp([10, 'Marker number argument has to be numeric.' 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
    d=mcgetmarker(d, mnum);
end

if nargin==2
    w=4;
    hop=2;
end

if nargin==3
    hop=2;
end

if ~isnumeric(w) || ~isnumeric(hop) || length(hop)>1 || length(hop)>1
    disp([10, 'Window and hop arguments have to be single numerics.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

rect=[];

if isfield(d,'type') && (strcmp(d.type, 'MoCap data'))
    for k=1:d.nMarkers
        rtmp=[];
        for b=0:hop:(double(d.nFrames)/d.freq)-w
            ind1=int16(1+d.freq*b);
            ind2=int16(min(size(d.data,1), ind1+d.freq*w));
            tmp=d.data(ind1:ind2,k*3-2:k*3-1);%markers
            mintmp=min(tmp);
            maxtmp=max(tmp);
            rtmp = [rtmp (maxtmp(1)-mintmp(1))*(maxtmp(2)-mintmp(2))/1000000];
        end
        rtmp=rtmp';
        rect = [rect rtmp];
    end
else
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

br = rect;
