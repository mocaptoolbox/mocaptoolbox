function d2 = mc2local(d, m1, m2)
% Transforms MoCap data to a local coordinate system with the new origin given
% in m1. The data can further be rotated to be aligned to frontal view
% (on frame basis).
%
% syntax
% d2 = mc2local(d, m1);
% d2 = mc2local(d, m1, [m2, m3]);
%
% input parameters
% d: MoCap data structure
% m1: marker number being the new origin
% m2: numbers of the markers that define the frontal plane, given as vector
% of two numbers
%
% output
% d2: MoCap data structure
%
% examples
% d2 = mc2local(d, 1); %no rotation (to frontal view) performed
% d2 = mc2local(d, 1, [1 2]); %data rotated to frontal view based on markers 1 and 2
%
% comments
%
% see also
% mc2frontal, mcrotate
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland


if nargin<2
    disp([10, 'mc2frontal needs at least two input parameters.' 10])
    d2=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


if ~isnumeric(m1) || length(m1)>1
    disp([10, 'First marker number argument has to be single numerics.' 10])
    d2=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin==3
    if ~isnumeric(m2) || length(m2)<2 || length(m2)>2
        disp([10, 'Second marker number argument has to consist of two single numerics.' 10])
        d2=[];
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

d2=d;



if nargin==3 %in case rotation to frontal place is indicated
    d = mc2frontal(d, m2(1), m2(2), 'frame');
end

d2.data = d.data - repmat(d.data(:,3*m1-3+(1:3)), 1, d.nMarkers);
