function h = mcmocapgram(d, timetype)
% Plots mocapgram (shows positions of a large number of markers as projection
% onto a colorspace).
%
% syntax
% h = mcmocapgram(d);
% mcmocapgram(d);
% mcmocapgram(d,timetype);
%
% input parameters
% d: MoCap or norm data structure
% timetype: time type used in the plot ('sec' (default) or 'frame')
%
% output
% h: figure handle
%
% examples
% mcmocapgram(d,'frame');
% h = mcmocapgram(d);
%
% Script developed by Kristian Nymoen, University of Oslo, Norway
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data')
    if nargin<2
        timetype='sec';
    end
else
    disp([10, 'The first input argument should be a variable with MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    h=[];
    return
end

r = zeros(d.nMarkers,d.nFrames);
g = zeros(d.nMarkers,d.nFrames);
b = zeros(d.nMarkers,d.nFrames);

if strcmp(d.type, 'MoCap data')
    for i = 1:d.nMarkers
        for j = 1:d.nFrames
            r(i,j) = d.data(j,i*3-2);
            g(i,j) = d.data(j,i*3-1);
            b(i,j) = d.data(j,i*3);
        end
    end
end

if strcmp(d.type, 'norm data')
    for i = 1:d.nMarkers
        for j = 1:d.nFrames
            r(i,j) = d.data(j,i);
            g(i,j) = d.data(j,i);
            b(i,j) = d.data(j,i);
        end
    end
end

for i = 1:d.nMarkers
    r(i,:) = r(i,:)-min(r(i,:));r(i,:) = r(i,:)./max(r(i,:));
    g(i,:) = g(i,:)-min(g(i,:));g(i,:) = g(i,:)./max(g(i,:));
    b(i,:) = b(i,:)-min(b(i,:));b(i,:) = b(i,:)./max(b(i,:));
end
rgb(:,:,1) = r;
rgb(:,:,2) = g;
rgb(:,:,3) = b;

if nargout > 0
    h = figure;figure(gcf);
else
    figure;figure(gcf);
end

if strcmp(timetype,'frame')
    image([0 d.nFrames],[1 d.nMarkers],rgb)
    xlabel('time (frames)')
else
    image([0 d.nFrames/d.freq],[1 d.nMarkers],rgb)
    xlabel('time (s)')
end

ylabel('marker')

if ~isempty(d.markerName)
    if ischar(d.markerName{1})
        set(gca,'YTick',1:d.nMarkers,'YTickLabel',d.markerName)
    elseif iscell(d.markerName{1})
        set(gca,'YTick',1:d.nMarkers,'YTickLabel',[d.markerName{:}])
    else
        disp([10, 'unknown markerName type', 10])
    end
end
