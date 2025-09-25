function bb = mcboundrect(d, options)
% Calculates the bounding rectangle (the smallest rectangular area that contains the
% projection of the trajectory of each marker on the horizontal plane (i.e., floor). The function can alternatively calculate the bounding box (rectangular cuboid) of each marker trajectory, i.e. the smallest right rectangular prism volume containing it.
%
% syntax
% b = mcboundrect(d);
% b = mcboundrect(__,Name,Value);
%
% input parameters
% d: MoCap data structure
%
%  Name-value arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%   mnum (optional): marker numbers (if no value given, all markers are used)
%   type (optional):
%      - 'rectangle' (default) calculates the bounding rectangle area (in square metres) corresponding to the horizontal plane projection
%      - 'box' calculates the bounding box volume (in cubic metres) of each marker trajectory
%   w (optional): length of analysis window (default: 4 sec)
%   hop (optional): overlap of analysis windows (default: 2 sec)
%
% output
% b: data matrix (windows x nMarkers)
%
% examples
% b = mcboundrect(d);
% b = mcboundrect(d, mnum=[1 3 5]);
% b = mcboundrect(d, mnum=3, type='box');
% b = mcboundrect(d, mnum=[1:d.nMarkers], w=3, hop=1);
% b = mcboundrect(d, mnum=[3 5], type='box', w=3, hop=1);
%
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
% Part of the Motion Capture Toolbox, Copyright 2024,
% University of Jyvaskyla, Finland
arguments
    d
    options.mnum {mustBeVector}
    options.type = 'rectangle'
    options.w (1,1) {mustBeNumeric} = 4
    options.hop (1,1) {mustBeNumeric} = 2
end
if isfield(options,'mnum')
    mnum=options.mnum;
    d=mcgetmarker(d, mnum);
end
type=options.type;
w=options.w;
hop=options.hop;
bb=[];

if isfield(d,'type') && (strcmp(d.type, 'MoCap data'))
    for k=1:d.nMarkers
        rtmp=[];
        for b=0:hop:(double(d.nFrames)/d.freq)-w
            ind1=int16(1+d.freq*b);
            ind2=int16(min(size(d.data,1), ind1+d.freq*w));
            if options.type == lower("rectangle")
                tmp=d.data(ind1:ind2,k*3-2:k*3-1);
            elseif options.type == lower("box")
                tmp=d.data(ind1:ind2,k*3-2:k*3);
            end
            mintmp=min(tmp);
            maxtmp=max(tmp);
            if options.type == lower("rectangle")
                rtmp = [rtmp (maxtmp(1)-mintmp(1))*(maxtmp(2)-mintmp(2))/1000000];
            elseif options.type == lower("box")
                rtmp = [rtmp (maxtmp(1)-mintmp(1))*(maxtmp(2)-mintmp(2))*(maxtmp(3)-mintmp(3))/1000000000];
            end
        end
        rtmp=rtmp';
        bb = [bb rtmp];
    end
else
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end
