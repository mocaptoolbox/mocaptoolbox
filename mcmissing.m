function [mf, mm, mgrid] = mcmissing(d)
% Reports missing data per marker and frame. 
%
% syntax
% [mf, mm, mgrid] = mcmissing(d);
%
% input parameters
% d: MoCap or norm data structure.
%
% output
% mf: number of missing frames per marker
% mm: number of missing markers per frame
% mgrid: matrix showing missing data per marker and frame (rows correspond to frames and columns to markers
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    mf = sum(isnan(d.data(:,1:3:end)),1);
    mm = sum(isnan(d.data(:,1:3:end)),2);
    mgrid = isnan(d.data(:,1:3:end));
elseif isfield(d,'type') && strcmp(d.type, 'norm data')
    mf = sum(isnan(d.data(:,1:end)),1);
    mm = sum(isnan(d.data(:,1:end)),2);
    mgrid = isnan(d.data(:,1:end));
else
    disp([10, 'The first input argument should be a variable with MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    mf=[];
    mm=[];
    mgrid=[];
end

