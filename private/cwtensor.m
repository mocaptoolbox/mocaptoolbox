function [w,f] = cwtensor(d,FS,MINF,MAXF,beatRelOpts,varargin)
    % Generate a frequency x time x channel wavelet tensor from a multivarate time series
    %
    % syntax
    % [w,f] = cwtensor(d,FS,MINF,MAXF,varargin);
    %
    % input parameters
    %
    % d: multivariate signal (time x channel)
    % FS: sampling rate in Hz
    % MINF: minimum frequency included in Hz
    % MAXF: maximum frequency included in Hz
    % beatRelOpts: optional structure containing options for beat-relative CWT tensor
    % varargin: any input parameters recognized by the Matlab function cwt.m
    %
    % output
    %
    % w = wavelet tensor (frequency x time x channel)
    % f = frequencies of the wavelet transform (expressed as metric levels when
    % beat-relative CWT tensor is obtained)
    %
    % examples
    %
    % commments
    %
    % Requires Matlab Wavelet Toolbox.
    %
    % see also
    % mcgxwt, cwtensor
    %
    % references
    %
    % Toiviainen, P., & Hartmann, M. (2022). Analyzing multidimensional movement interaction with generalized cross-wavelet transform. Human Movement Science, 81, 102894.
    %
    % Part of the Motion Capture Toolbox, Copyright 2022,
    % University of Jyvaskyla, Finland
    for k=1:size(d,2)
        [w0 f0]=cwt(d(:,k),FS,varargin{:});
        w1=w0(f0>MINF & f0<MAXF,:);
        f=f0(f0>MINF & f0<MAXF);
        if ~isempty(beatRelOpts)
            [w_,f_] = getBeatRelativeCWT(w1, f, beatRelOpts.BPM,beatRelOpts.metricRange,beatRelOpts.freqBandsPerOctave,'NoFigure');
        end
        if k==1 % allocate
            w=zeros(size(w1,1),size(w1,2),size(d,2));
            if ~isempty(beatRelOpts)
                w__=zeros(size(w_,1),size(w_,2),size(d,2));
            end
        end
        w(:,:,k)=w1;
        if ~isempty(beatRelOpts)
            w__(:,:,k)=w_;
        end
    end
    if ~isempty(beatRelOpts)
        w = w__;
        f = f_;
    end

    function [w ml] = getBeatRelativeCWT(w0,f0,BPM,metricRange,freqBandsPerOctave,plotFigures)
    % INPUT ARGUMENTS:
    % w0 (matrix): Continuous wavelet transform obtained via cwt()
    % f0 (vector): Frequencies of the continuous wavelet transform in Hz
    % BPM (positive integer): beats per minute of the music danced to, e.g.: 120
    % metricRange (two-element scalar vector): target range of metric levels (in beat subdivisions or multiples), e.g.: [1/2 8]
    % freqBandsPerOctave (positive integer): number of frequency bands per octave (larger values will increase frequency resolution), e.g. = 2^4;
    % plotFigures ('YesFigure' | 'NoFigure'): Optional indicator to display the beat relative continuous wavelet transform. 'YesFigure' is the default option. 'NoFigure' only returns the output arguments.
    % OUTPUT ARGUMENTS:
    % w (matrix): Beat-relative continuous wavelet transform
    % ml (vector): Metric level (in beats) associated with each row of w
        if nargin == 5
            plotFigures = 'YesFigure';
        end
        tactusfreq = BPM/60;
        numOctaves = log2(metricRange(2)/metricRange(1)); % Because octaves of a note occur at 2^n times the frequency of that note
        ml=logspace(log10(metricRange(1)),log10(metricRange(2)),numOctaves*freqBandsPerOctave+1);
        f = tactusfreq./ml;
        w = interp1(f0,w0,f);
        if strcmpi(plotFigures, 'YesFigure');
            figure
            imagesc(abs(w))
            i = 1:length(ml);
            yticks(i(1:freqBandsPerOctave:end))
            yticklabels(ml(1:freqBandsPerOctave:end))
            title(['BPM = ' num2str(BPM)]);
            ylabel('Metric level / Beats')
            xlabel('Time / Frames')
        elseif strcmpi(plotFigures, 'NoFigure');
        end
        ml = ml';
    end
end
