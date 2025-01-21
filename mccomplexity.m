function c = mccomplexity(d, mnum)
% Calculates the omega complexity (effective dimensionality) of movement based the Shannon entropy of simplex-normalised movement data eigenvalues. A high value indicates a high complexity, whereas a low value indicates low complexity.
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
% Del Giudice M. Effective Dimensionality: A Tutorial.
% Multivariate Behav Res. 2021 May-Jun;56(3):527-542.
% doi: 10.1080/00273171.2020.1743631.
% Epub 2020 Mar 29. PMID: 32223436.
%
% Part of the Motion Capture Toolbox, Copyright 2022,
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
