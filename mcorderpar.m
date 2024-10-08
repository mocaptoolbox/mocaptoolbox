function [MRVL MRVA] = mcorderpar(d,tempoOrBeatTimes,options)
% Computes phase locking of MoCap data relative to a cosine wave starting at t0.
% Evaluation can be performed at one or multiple metric levels.
% The function outputs the Kuramoto order parameter (mean resultant vector length and mean resultant vector angle). Note: it is recommended to compute phase locking from velocity data. The function does not work with position data.
%
% Syntax
% [mrvl, mrva] = mcorderpar(d, tempo);
% [xs, f, p1, p2] = mcgxwt(___, Name, Value);
%
% Input Parameters
% d: MoCap or Norm data structure
% tempoOrBeatTimes: When tempoOrBeatTimes is a single value (scalar), it represents the tempo of the cosine wave used for period locking estimation, measured in beats per minute (BPM).
%                   When tempoOrBeatTimes is a vector, it represents the times of individual beats in seconds.
%
% Name-Value Arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN,
% where Name is the argument name and Value is the corresponding value.
% Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%   t0 (optional): Time (in seconds) of the first (sub-/super-)beat relative to the movement data.
%       A positive or negative t0 value can be used to introduce a positive or negative delay to the cosine wave, respectively. Note: t0 should be set only when tempoOrBeatTimes is a scalar.
%       Default value = 0.
%   metricLevel (optional): Metric level(s) of analysis to use.
%       Default value is [0.5, 1, 2], corresponding to 1/2-beat level, 1 beat level, and 2-beat level. Note: metric level should be set only when tempoOrBeatTimes is a scalar.
%   bandpass (optional): Applies bandpass filtering using a bandwidth of 40% of the center frequency (default: true). Note: bandpass filtering is only applied when when tempoOrBeatTimes is a scalar.
%   plot (optional): When set to true, the function produces a polar plot for each combination of marker and movement direction,
%       displaying the phase difference separately for each metric level (default: `false`).
%
% Output
% MRVL: Mean resultant vector length of directional data at beat locations or at locations of beat multiples of subdivisions. MRVL ranges between 0 and 1.
% MRVA: Mean resultant vector angle of directional data at beat locations or at locations of beat multiples of subdivisions (in radians). MRVA ranges between -pi and pi.
%
% Examples
% g = mcgetmarker(dance2, {'Head_FL', 'Head_FR', 'Finger_L', 'Finger_R'});
% d = mctimeder(g);
% [l, a] = mcorderpar(d, 120, 'plot', true);
%
% [l, a] = mcorderpar(d, 120, 'plot', true, 't0', -1, 'metricLevel', 1:2);
%
% Comments
%
%
%
% See Also
% mcperiod, mccoupling, mcplotphaseplane
%
% References
% Phillips-Silver, J., Toiviainen, P., Gosselin, N., Piché, O., Nozaradan, S., Palmer, C., & Peretz, I. (2011).
% Born to dance but beat deaf: A new form of congenital amusia. Neuropsychologia, 49(5), 961-969.
%
% Part of the Motion Capture Toolbox, Copyright 2024,
% University of Jyvaskyla, Finland
    arguments
        d struct {mustNotBePos}
        tempoOrBeatTimes {mustBeNumeric,mustBeNonnegative,mustBeFinite,mustBeVector}
        options.t0 (1,1) {mustBeNumeric,mustBeFinite} = 0 % delay of cosine wave in seconds
        options.metricLevel {mustBeNumeric,mustBeVector} = [.5 1 2] % metric level; default: 1/2-beat, 1-beat, 2-beat
        options.bandpass logical = true
        options.plot logical = false
    end
    if isscalar(tempoOrBeatTimes)
        tempo = tempoOrBeatTimes;
    else % must be vector
        beat_times = tempoOrBeatTimes;
    end
    if isscalar(tempoOrBeatTimes)
        f0 = tempo/60;% beat frequency in hertz
        if true(options.bandpass)
            d = mcbandpass(d,.8*f0, 1.2*f0);
        end
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
    if exist('tempo','var')
        shift = d.freq*options.t0;
        t = 0:1/d.freq:durs;
        t = t(1:end-1);
        x=cos(2*pi*f0*t-shift); %generate a cosine wave (or a shifted version of it) at a beat frequency that corresponds with the tempo
        ph = unwrap(angle(hilbert(x)))';
    end

    if exist('tempo','var')
        coef = 1./options.metricLevel;
        pha = unwrap(angle(hilbert(dd))); % get analytic signal and then unwrapped phase
    elseif exist('beat_times')
        coef = 1;
        hil = hilbert(dd);
        hil = hil./abs(hil);
        pha = angle(hil); % get analytic signal
    end

    for j = 1:numel(coef) % each beat level
        mb = coef(j)*durs; % number of beats
        BF = coef(j);
        if exist('tempo','var')
            BL = 60/(BF*tempo);% beat length in seconds for a given beat level
            beats=(0:mb)*BL; % beat location in seconds
            dph = BF*ph-pha; % difference between unwrapped phase of cosine wave (scaled to target beat level) and unwrapped phase of data
            dphBeats = interp1(t,dph,beats);% interpolate so as to get the unwrapped phase difference at each beat
            dirVecComp = cos(dph)+i*sin(dph); % directional data, expressed as complex numbers of unit magnitude
            dirVecRad = atan2(imag(dirVecComp),real(dirVecComp)); % directional data, in radians
            dphBeatsDirVecComp = cos(dphBeats)+i*sin(dphBeats); % directional data at (sub/super) beat locations, expressed as complex numbers of unit magnitude
            dphBeatsDirVecRad = atan2(imag(dphBeatsDirVecComp),real(dphBeatsDirVecComp)); % directional data at (sub/super) beat locations, in radians
        elseif exist('beat_times','var')
            beats = 1+round(beat_times*d.freq); % beat location in frames
            dphBeatsDirVecComp = hil(beats,:);
            dphBeatsDirVecRad = pha(beats,:);
        end

        MRV = mean(dphBeatsDirVecComp); % mean resultant vector of directional data
        MRVL(j,:) = abs(MRV);
        MRVA(j,:) = angle(MRV);
        if true(options.plot)
            figure, tiledlayout('flow','TileIndexing','ColumnMajor')
            for k = 1:width(dd)
                nexttile
                orderparpolar(dphBeatsDirVecRad(:,k),1:numel(beats));
                title(dimNames{k},'Interpreter','none')
            end
            if exist('tempo','var')
                sgtitle(['Phase difference for ' num2str(options.metricLevel(j)) '-beat level'])
            elseif exist('beat_times','var')
                sgtitle('Phase difference')
            end
        end
    end
end
function orderparpolar(dirvectorsradians,dd)
    polarplot(dirvectorsradians,dd,'-ok');
    pax = gca;
    pax.ThetaZeroLocation='top';
end
