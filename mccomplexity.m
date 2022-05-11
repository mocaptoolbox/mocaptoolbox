function c = mccomplexity(d, mnum)
% Calculates the complexity of movement based on entropy of the proportion
% of variance contained in the principal components. A high value indicates 
% a high complexity, whereas a low value indicated low complexity.
%
% syntax
% c = mccomplexity(d, mnum);
%
% input parameters
% d: MoCap data structure
% mnum: marker numbers (optional; if no value given, all markers are used)
%
% output
% c: complexity value, between 0 and 1
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

if sum(mcmissing(d))>0
    d=mcfillgaps(d);
    disp([10, 'Missing frames filled.' 10])
end


tmp=mcgetmarker(d,mnum);
[pc,p]=mcpcaproj(tmp,1:(3*tmp.nMarkers));
p.l=max(p.l,0);
c=entropy(p.l);



