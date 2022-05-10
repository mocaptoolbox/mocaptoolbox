function f = mcfluidity(d, mnum)
% Calculates the fluidity/circularity of mocap data, defined as the ratio 
% between velocity and acceleration of the normed and averaged mocap data.
%
% syntax
% f = mcfluidity(d, mnum);
%
% input parameters
% d: MoCap data structure
% mnum: marker numbers (optional; if no value given, all markers are used)
%
% output
% f: fluidity value (the higher the value, the higher the
% smoothness/fluidity)
%
% examples
% f = mcfluidity(d, 4:6);
%
% references
% Burger, B., Saarikallio, S., Luck, G., Thompson, M. R. & Toiviainen, P. (2013). 
% Relationships between perceived emotions in music and music-induced movement. 
% Music Perception 30(5), 519-535.
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

f=[];

if ~isfield(d,'type') || ~strcmp(d.type, 'MoCap data')
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin==1
    mnum=1:d.nMarkers;
end

if ~isnumeric(mnum)
    disp([10, 'Marker number argument has to be numeric.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


dd=mcgetmarker(d,mnum);
v=mctimeder(dd);
a=mctimeder(v);
vm=mcmean(mcnorm(v));
am=mcmean(mcnorm(a));
f=vm/am;

