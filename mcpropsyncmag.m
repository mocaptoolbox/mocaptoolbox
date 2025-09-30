function p = mcpropsyncmag(d,tempoOrBeatTimes,options)
% Computes proportion of synchronized magnitude of MoCap data for a target tempo in BPM or for a target vector with individual beat times (in seconds). A wavelet transform -based dynamic bandpass filtering is applied.
%
% Syntax
% p = mcorderpar(d, beatTimes);
%
% Input Parameters
% d: MoCap or Norm data structure
% tempoOrBeatTimes: When tempoOrBeatTimes is a single value (scalar), it represents the tempo of the cosine wave used for period locking estimation, measured in beats per minute (BPM).
%
% Name-Value Arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN,
% where Name is the argument name and Value is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%
%   bwRatio (optional): Sets the relative bandwidth of the bandpass filter (default: 0.4). For instance, when specifying a relative bandwidth of .3, the bandpass filter will use a bandwidth of 30% of the center frequency. To be used only when bandpass is set to true.
%
%   plot (optional): When set to true, the function produces a plot of the GXWTs (default: `false`).

% Output
% p: proportion of synchronized power around target tempo or instantaneous beat frequencies
%
% Examples
%
% load mcdemodata
% g = mcgetmarker(dance2,'Head_FL')
% mcpropsyncmag(g,120)
% mcpropsyncmag(g,120,plot=1)
%
% g = mcgetmarker(walk1, 'Ankle_R');
% AnkleRStep = [1.01667 2.1 3.28333 4.38333 5.51667];
% mcpropsyncmag(g,AnkleRStep,plot=1)
%
% Comments
%
% See Also
% mcperiod
%
% Part of the Motion Capture Toolbox, Copyright 2025,
% University of Jyvaskyla, Finland
    arguments
        d struct
        tempoOrBeatTimes {mustBeNumeric,mustBeNonnegative,mustBeFinite,mustBeVector}
        options.bwRatio (1,1) {mustBeFinite,mustBePositive} = .4
        options.plot logical = false
    end
    if isscalar(tempoOrBeatTimes)
        tempo = tempoOrBeatTimes;
    else % must be vector
        beat_times = tempoOrBeatTimes;
    end
    dd = d.data;
    durs = (d.nFrames/d.freq);
    dims = 1:width(d.data)/numel(d.markerName);
    if d.type == "MoCap data"
        dimNames = [string(d.markerName) + ", dim. " + string(dims)]';
        dimNames = dimNames(:);
    elseif d.type == "norm data"
        dimNames = string(d.markerName);
    end
    t = (0:(1/d.freq):durs)';
    if isscalar(tempoOrBeatTimes)
        f = repmat(tempo/d.freq,size(t,1)-1,1);
    else
        nbtt = numel(beat_times)-1;
        % estimate instantaneous beat frequency in Hz for each mocap time point
        phase = interp1(beat_times,0:nbtt,t,'spline');
        f=diff(phase)*d.freq;
    end
    % calculate WT of movement data
    for j = 1:width(dd)
        [wt{j} wfreq{j}] =cwt(dd(:,j),d.freq);
        for k = 1:size(wt{j},2)
            scale(:,k)=normpdf(wfreq{j},f(k),options.bwRatio*f(k));
            scale(:,k)=scale(:,k)/max(scale(:,k));
            wt2{j}(:,k)=wt{j}(:,k).*scale(:,k);
        end
        wt2{j}(isnan(wt2{j})) = 0;
        p(j,:) = mean(sum(abs(wt2{j}),'all')/sum(abs(wt{j}),'all'));
    end
    if true(options.plot)
        figure, tiledlayout('flow','TileIndexing','ColumnMajor')
        for k = 1:width(dd)
            nexttile
            linf = linspace(wfreq{k}(1),wfreq{k}(end),1000);
            w = interp1(wfreq{k},abs(wt2{k}),linf);
            imagesc(t, linf, w); % Replace 'time' with your actual time vector
            set(gca, 'YDir', 'normal');  % Correct orientation
            colormap(turbo);             % Use a perceptually uniform colormap
            colorbar;                    % Add color scale
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            ylim([0,10])
            title(dimNames{k},'Interpreter','none')
        end
        sgtitle('Dynamic bandpass filtered Continuous Wavelet Transform (CWT) Scalogram')

    end

end
