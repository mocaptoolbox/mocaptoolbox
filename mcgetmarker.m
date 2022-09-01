function d2 = mcgetmarker(d, mn)
% Extracts a subset of markers.
%
% syntax
% d2 = mcgetmarker(d, mn);
%
% input parameters
% d: MoCap or norm data structure
% mn: vector containing the numbers of markers to be extracted or string or cell array containg names of markers (case sensitive).
%
% output
% d2: MoCap structure
%
% examples
% d2 = mcgetmarker(d, [1 3 5]);
% d2 = mcgetmarker(d,'Sternum');
% d2 = mcgetmarker(d,{'BigToe_L','BigToe_R'});
%
% See also
% mcsetmarker, mcconcatenate
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if iscell(mn)
    mnum = arrayfun(@(x) find(contains(d.markerName,x)),mn);
elseif ischar(mn)
    mnum = find(contains(d.markerName,mn));
else
    mnum = mn;
end

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    if min(mnum)<1 || max(mnum)>d.nMarkers
        disp([10, 'Marker numbers are out of range.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
    d2 = d;
    columns=[];
    for k=1:length(mnum)
        columns=[columns 3*mnum(k)+(-2:0)];
    end
    d2.data = d.data(:, columns);
    d2.nMarkers = length(mnum);
    d2.markerName = d.markerName(mnum);

elseif isfield(d,'type') && strcmp(d.type, 'norm data')
    if min(mnum)<1 || max(mnum)>d.nMarkers
        disp([10, 'Marker numbers are out of range.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
    d2 = d;
    columns=[];
    for k=1:length(mnum)
        columns=[columns mnum(k)];
    end
    d2.data = d.data(:, columns);
    d2.nMarkers = length(mnum);
    d2.markerName = d.markerName(mnum);

else
    disp([10, 'The first input argument has to be a variable with MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
