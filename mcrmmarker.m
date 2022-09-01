function d2 = mcrmmarker(d, mn)
% Removes a subset of markers.
%
% syntax
% d2 = mcrmmarker(d, mn);
%
% input parameters
% d: MoCap or norm data structure
% mn: vector containing the numbers of markers to be removed or string or cell array containg names of markers (case sensitive).
%
% output
% d2: MoCap structure
%
% examples
% d2 = mcrmmarker(d, [1 3 5]);
% d2 = mcrmmarker(d,'Sternum');
% d2 = mcrmmarker(d,{'BigToe_L','BigToe_R'});
%
% See also
% mcgetmarker, mcsetmarker, mcconcatenate
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
markerIndices=1:d.nMarkers;
selectionIndices = markerIndices(~ismember(markerIndices,mnum));
d2 = mcgetmarker(d,selectionIndices);
