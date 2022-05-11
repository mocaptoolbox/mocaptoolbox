function c = mccomplexity(d, mnum)
% Calculates the omega complexity of movement based on entropy of the proportion
% of variance contained in the principal components.
%
% syntax
% c = mccomplexity(d, mnum);
%
% input parameters
% d: MoCap data structure
% mnum: marker numbers (optional; if no value given, all markers are used)
%
% output
% c: complexity value, the larger the more complex
%
% examples
% c = mccomplexity(d);
% c = mccomplexity(d,4:7);
%
% comments
% Data will be filled in case of missing frames.
%
% see also
% mcpcaproj
%
% references
% Burger, B., Saarikallio, S., Luck, G., Thompson, M. R. & Toiviainen, P. (2013).
% Relationships between perceived emotions in music and music-induced movement.
% Music Perception 30(5), 519-535.
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

c=[];

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

tmp=mcgetmarker(d,mnum); %BBFIX: change command order to only gapfill relevant part of data
if sum(mcmissing(tmp))>0
    tmp=mcfillgaps(tmp);
    disp([10, 'Missing frames filled.' 10])
end


[pc,p]=mcpcaproj(tmp,1:(3*tmp.nMarkers));
p.l=max(p.l,eps);
c=exp(-sum(p.l.*log(p.l)));
c=c*sum(var(tmp.data)); %BBEDIT20201110: reduce noise in recordings with little movement / scale data according to their variance / distribution
