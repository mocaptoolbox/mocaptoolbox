function p = mcs2posture(d)
% Creates a posture representation from segm data by setting root transition
% and root rotation to zero values.
%
% syntax
% p = mcs2posture(d);
%
% input parameters
% d: segm data structure
%
% output
% p: segm data structure
%
% see also
% mcj2s
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if isfield(d,'type') && strcmp(d.type, 'segm data')
    p = d;
    p.roottrans=0*p.roottrans;
    p.rootrot.az=0*p.rootrot.az;
    p.rootrot.el=0*p.rootrot.el;
else
    disp([10, 'The  input argument has to be a variable with segm data structure.', 10]);
    p=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
