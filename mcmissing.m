function [mf, mm, mgrid] = mcmissing(d,options)
arguments
    d
    options.plot matlab.lang.OnOffSwitchState = 1
end
% Reports missing data per marker and frame.
%
% syntax
% [mf, mm, mgrid] = mcmissing(d);
%
% input parameters
% d: MoCap or norm data structure.
%
% 'plot' (optional): when set to true (default), mcmissing visualizes missing data
%
% output
% mf: number of missing frames per marker
% mm: number of missing markers per frame
% mgrid: matrix showing missing data per marker and frame (rows correspond to frames and columns to markers
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if ~isfield(d,'type') | ~(strcmp(d.type, 'MoCap data') | strcmp(d.type, 'norm data'))
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    error('The first input argument should be a variable with MoCap or norm data structure.');
end

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    mf = sum(isnan(d.data(:,1:3:end)),1);
    mm = sum(isnan(d.data(:,1:3:end)),2);
    mgrid = isnan(d.data(:,1:3:end));
elseif isfield(d,'type') && strcmp(d.type, 'norm data')
    mf = sum(isnan(d.data(:,1:end)),1);
    mm = sum(isnan(d.data(:,1:end)),2);
    mgrid = isnan(d.data(:,1:end));
end

if options.plot == true
    figure
    subplot(3,1,1), bar(mf), xlabel('Marker'), ylabel({'Number of'; 'missing frames'})
    subplot(3,1,2), bar(mm), xlabel('Frame'), ylabel({'Number of'; 'missing markers'})
    c=gray(2);
    subplot(3,1,3), imagesc(-mgrid'), colormap(c), xlabel('Frame'), ylabel('Marker')
end
