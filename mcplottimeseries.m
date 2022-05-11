function mcplottimeseries(varargin)
% Plots motion capture data as time series.
%
% syntax
% mcplottimeseries(d, marker) % for MoCap or norm data structure
% mcplottimeseries(d, marker, 'dim', dim) % specifying dimensions to be plotted
% mcplottimeseries(d, marker, 'timetype', timetype) % axis unit
% mcplottimeseries(d, marker, 'plotopt', plotopt) % combined or separate plots
% mcplottimeseries(d, marker, 'label', label) % y-axis label
% mcplottimeseries(d, marker, 'names', names) % marker names
% mcplottimeseries(s, segm, 'var', var) % for segm data structure
% mcplottimeseries(s, segm, 'plotarr', var) % vertical or horizontal subplot arrangement
%
% input parameters
% d/s: MoCap data structure, norm data structure, or segm data structure
% marker: vector containing marker numbers or cell array containing marker names (for MoCap or norm data structure)
% segm: body segment numbers or cell array containing segment names (for segm data structure)
% dim: dimensions to be plotted (for MoCap data structure - default: 1)
% var: variable to be plotted for segment segm (for segm data structure - default: 1)
% timetype: time type used in the plot ('sec' (seconds - default) or 'frame')
% plotopt: plotting option (for MoCap or norm data structure); 'sep' (default) or 'comb':
%   sep: all time series  are plotted in separate subplots
%   comb: all time series will be plotted into the same plot using different colors)
% label: y-axis label (default: no y-axis label). X-axis label is always set, according to timetype
%   (however, for plotting neither x-axis nor y-axis labels: 'label', 0)
% names: if marker names (instead of numbers) are plotted in title and legend (0: numbers (default), 1: names)
% plotarr: arrangement of subplots; 'v' (default) or 'h' (only relevant when plotopt is set to 'sep' and more than one dim/marker is plotted):
%    'v': vertical: subplots above each other
%    'h': horizontal: subplots next to each other
%
% output
% Figure.
%
% examples
% mcplottimeseries(d, 2) % MoCap or norm data structure, marker 2, dim 1
% mcplottimeseries(d, {'Head_FL','Finger_L'}) %marker names instead of numbers (works for segments as well)
% mcplottimeseries(d, 1:3, 'dim', 1:3) % markers 1 to 3, dimensions 1 to 3
% mcplottimeseries(d, 1:3, 'dim', 3, 'timetype', 'frame') % frames as x axis unit
% mcplottimeseries(d, 5, 'dim', 1:3, 'plotopt', 'comb') % all in one plot, different colors per dim
% mcplottimeseries(d, 5, 'dim', 1:3, 'plotopt', 'comb', 'label', 'mm') % y-axis label: mm
% mcplottimeseries(d, 5, 'dim', 1:3, 'timetype', 'frame', 'label', 0) % no x- axis (and no y-axis) label
% mcplottimeseries(d, 5, 'names', 1) % marker names (instead of numbers) plotted in title and legend
% mcplottimeseries(d, 5, 'dim', 1:3, 'plotarr', 'h') % subplots horizontal
% mcplottimeseries(s, [3 6 20], 'var', 'angle') % for segm data structure
% mcplottimeseries(s, 5:10, 'var', 'eucl', 'timetype', 'frame') % frames as x axis unit
% mcplottimeseries(s, [12 14], 'var', 'quat', 'dim', 2, 'plotopt', 'comb') % all in one plot, component 2
% comment
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland


% New syntax [BB 20110131]:

% for backwards compatibility for users, who haven't adapted their syntax yet
if nargin>2
    if (strcmp(varargin{3},'dim') + strcmp(varargin{3},'var') + strcmp(varargin{3},'timetype') + ...
            strcmp(varargin{3},'plotopt') + strcmp(varargin{3},'label') + strcmp(varargin{3},'names') + strcmp(varargin{3},'plotarr')) == 0
        disp([10, 'Warning: You are using an old version of mcplottimeseries. Please consider adapting your syntax to the new version.'])
        disp(['For more information, check the Mocap Toolbox manual.', 10])
        mcplottimeseries_dep(varargin{1:end});
        return
    end
end

d=varargin{1};
marker=varargin{2};

dim=[];
var=[];
timetype=[];
plotopt=[];
label=[];
names=[];
plotarr=[];

for k=3:2:length(varargin)
    if strcmp(varargin{k}, 'dim')
        dim=varargin{k+1};
    elseif strcmp(varargin{k}, 'var')
        var=varargin{k+1};
    elseif strcmp(varargin{k}, 'timetype')
        timetype=varargin{k+1};
    elseif strcmp(varargin{k}, 'plotopt')
        plotopt=varargin{k+1};
    elseif strcmp(varargin{k}, 'label')
        label=varargin{k+1};
    elseif strcmp(varargin{k}, 'names')
        names=varargin{k+1};
    elseif strcmp(varargin{k}, 'plotarr')
        plotarr=varargin{k+1};
    else
        str=sprintf('Input argument %s unknown.', varargin{k});
        disp([10, str, 10])
%         [y,fs] = audioread('mcsound.wav');
%         sound(y,fs);
%         return
    end
end


%set default values and check for incorrect spelling

if isempty(dim)
    dim=1;
end

if strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data')
    if max(dim)>size(d.data,2)/d.nMarkers
        disp([10, 'Dimension (dim) value exceeds existing dimensions (no plot created).', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

if strcmp(d.type, 'segm data')
    if isempty(var)
        disp([10, 'Please specify segment variable (var) to be plotted (no plot created).', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
    if strcmp(var,'angle')
        if max(dim)>1
            disp([10, 'Dimension (dim) value exceeds existing dimensions (no plot created).', 10])
            [y,fs] = audioread('mcsound.wav');
            sound(y,fs);
            return
        end
    elseif strcmp(var,'eucl')
        if max(dim)>3
            disp([10, 'Dimension (dim) value exceeds existing dimensions (no plot created).', 10])
            [y,fs] = audioread('mcsound.wav');
            sound(y,fs);
            return
        end
    elseif strcmp(var,'quat')
        if max(dim)>4
            disp([10, 'Component (dim) value exceeds existing components (no plot created).', 10])
            [y,fs] = audioread('mcsound.wav');
            sound(y,fs);
            return
        end
    end
end

if isempty(timetype)
    timetype='sec';
end
if strcmp(timetype,'sec') || strcmp(timetype,'frame')
else
    timetype='sec';
    disp([10, 'Incorrect spelling of timetype input. Value set to "sec".', 10])
end

if isempty(plotopt)
    plotopt='sep';
end
if strcmp(plotopt,'sep') || strcmp(plotopt,'comb')
else
    plotopt='sep';
    disp([10, 'Incorrect spelling of plotopt input. Value set to "sep".', 10])
end

if isempty(plotarr)
    plotarr='v';
end
if strcmp(plotarr,'v') || strcmp(plotarr,'h')
else
    plotarr='v';
    disp([10, 'Incorrect spelling of plotarr input. Value set to "v".', 10])
end
%TODO catch plotopt=comb not compatible with plotarr - and also only works
%if dim is larger than 1 or marker is larger than 1...

if isempty(names)
    names=0;
end
if names>1
    disp([10, 'Names input bigger than 1 or in incorrect format, value is set to 1.', 10])
    names=1;
end

if strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data') || strcmp(d.type, 'segm data')
else
    disp([10, 'The first input argument should be a variable with MoCap, norm, or segm data structure (no plot created).', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin<2
    disp([10, 'Please specify data and/or markers (or segments) to be plotted (no plot created).', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if iscell(marker)
    marker=name2number(d,marker);
    if isempty(marker) %no plot created if all markers that are given are misspelled
        disp([10, 'Please specify data and/or markers (or segments) to be plotted (no plot created).', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

if ischar(marker) %if string is entered
    disp([10, 'Marker number has to be either numbers or cell array with marker names (no plot created).', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end
if max(marker)>d.nMarkers
    disp([10, 'Marker number out of range (no plot created).', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


p1=marker;
p2=dim;

set(0,'DefaultTextInterpreter','none') %for underscores (and such) in marker names

colors={'blue', 'green', 'red', 'cyan', 'magenta', 'yellow', 'black'};

if isfield(d,'type')
    t = (1:d.nFrames)';%-1 taken away as it caused time series to start at 0... [BB 20110301]
    if strcmp(timetype,'sec')
        t = (t-1)/d.freq; %t-1 to start at 0.0s [BB 20190509]
    end
    if strcmp(d.type, 'MoCap data')
        figure
        al=1;%amount of lines - for 'comb' plotting
        for k=1:length(p1)
            for m=1:length(p2)
                if strcmp(plotopt, 'sep')
                    if strcmp(plotarr, 'h')
%                         subplot(length(p1), length(p2), length(p2)*(k-1)+m)
                        subplot(length(p1), length(p2), length(p1)*(k-1)+m)
                    else subplot(length(p2), length(p1), length(p2)*(k-1)+m)
                    end
                    pl=plot(t, d.data(:,3*p1(k)-3+p2(m)));
                    axis([min(t) max(t) -Inf Inf])
                    if names==0
                        title(['Marker ' num2str(p1(k)) ', dim. ' num2str(p2(m))])
                    elseif names==1
                        title(['Marker ' char(d.markerName{p1(k)}) ', dim. ' num2str(p2(m))])
                    end
                else
                    pl=plot(t, d.data(:,3*p1(k)-3+p2(m)));
                    axis([min(t) max(t) -Inf Inf])
                    set(pl,'color',colors{mod(al-1,7)+1}) %al has 7 colors, should start over with blue after 7 lines
                    if names==0
                        title(['Marker [' num2str(p1) '], dim. [' num2str(p2) ']'])
                        st{al} = ['M. ' num2str(p1(k)) ', dim. ' num2str(p2(m))];
                    elseif names==1
                        title(['Marker [' num2str(p1) '], dim. [' num2str(p2) ']'])
                        st{al} = ['M. ' char(d.markerName{p1(k)}) ', dim. ' num2str(p2(m))];
                    end
                    al=al+1;
                    hold on
                end
                if ~isscalar(label) %if label is [] or string, then plot labels
                    if strcmp('sec',timetype)
                        xlabel('seconds')
                    else xlabel('frames')
                    end
                    if ~isempty(label)
                        ylabel(label)
                    end
                end
            end
        end
        if strcmp(plotopt, 'comb') %plot legend
            leg=legend(st, 'Location', 'EastOutside');
        end
    elseif strcmp(d.type, 'norm data')
        figure
        al=1;%amount of lines - for 'comb' plotting
        plot(t, d.data(:,p1));
        for k=1:length(p1)
            for m=1%:length(p2)
                if strcmp(plotopt, 'sep')
                    if strcmp(plotarr, 'h')
                        subplot(1, length(p1), k)
                    else subplot(length(p1), 1, k)
                    end
                    plot(t, d.data(:,p1(k)))
                    axis([min(t) max(t) -Inf Inf])
                    if names==0
                        title(['Marker ' num2str(p1(k)) ', norm data'])
                    elseif names==1
                        title(['Marker ' char(d.markerName{p1(k)}) ', norm data'])
                    end
                else
                    pl=plot(t, d.data(:,p1(k))); %FIXBB110102: 'comb' also for norm data
                    axis([min(t) max(t) -Inf Inf])
                    set(pl,'color',colors{mod(al-1,7)+1}) %al has 4 colors, should start over with blue after 7 lines

%                     title(['Marker [' num2str(p1) '], norm data'])
                    if names==0
                        title(['Marker [' num2str(p1) '], norm data'])
                        st{al} = ['M. ' num2str(p1(k))];
                    elseif names==1
                        title(['Marker [' num2str(p1) '], norm data'])
                        st{al} = ['M. ' char(d.markerName{p1(k)})];
                    end

                    al=al+1;
                    hold on
                end
                if ~isscalar(label) %if label is [] or string, then plot labels
                    if strcmp('sec',timetype)
                        xlabel('seconds')
                    else xlabel('frames')
                    end
                    if ~isempty(label)
                        ylabel(label)
                    end
                end
            end
        end
        if strcmp(plotopt, 'comb') %plot legend
            legend(st, 'Location', 'EastOutside');
        end

    elseif strcmp(d.type, 'segm data')
        figure
        tmp=[];
        al=1;%amount of lines - for 'comb' plotting
        for k=1:length(p1)
            tmp = getfield(d.segm(p1(k)),var);
            if ~isempty(tmp)
                if strcmp(var, 'angle')
                    if strcmp(plotopt, 'sep')
                        % k
                        if strcmp(plotarr, 'h')
                            subplot(1, length(p1), k)
                        else subplot(length(p1), 1, k)
                        end
                        plot(t, tmp)
                        axis([min(t) max(t) -Inf Inf])
                        if names==0
                            title(['Segm. ' num2str(p1(k)) ' - angle'])
                        elseif names==1
                            title(['Segm. ' char(d.segmentName{p1(k)}) ' - angle'])
                        end
                    else
                        pl=plot(t, tmp); %FIXBB201202010: 'comb' also for segm data
                        axis([min(t) max(t) -Inf Inf])
                        set(pl,'color',colors{mod(al-1,7)+1}) %al has 4 colors, should start over with blue after 7 lines
                        if names==0
                            title(['Segm. [' num2str(p1) '] - angle'])
                            st{al} = ['Segm. ' num2str(p1(k))];
                        elseif names==1
                            title(['Segm. [' num2str(p1) '] - angle'])
                            st{al} = ['Segm. ' char(d.segmentName{p1(k)})];
                        end
                        al=al+1;
                        hold on
                    end
                    if ~isscalar(label) %if label is [] or string, then plot labels
                        if strcmp('sec',timetype)
                            xlabel('seconds')
                        else xlabel('frames')
                        end
                        if ~isempty(label)
                            ylabel(label)
                        end
                    end
                elseif strcmp(var, 'eucl')
                    for m=1:length(p2)
                        if strcmp(plotopt, 'sep')
                            if strcmp(plotarr, 'h')
                                subplot(length(p2), length(p1), length(p2)*(k-1)+m)
                            else subplot(length(p1), length(p2), length(p2)*(k-1)+m)
                            end
                            plot(t, tmp(:,p2(m)))
                            if names==0
                                title(['Segm. ' num2str(p1(k)) ', dim. ' num2str(p2(m)) ' - eucl']);
                            elseif names==1
                                title(['Segm. ' char(d.segmentName{p1(k)}) ', dim. ' num2str(p2(m)) ' - eucl'])
                            end
                            axis([min(t) max(t) -Inf Inf])
                        else
                            pl=plot(t, tmp(:,p2(m))); %FIXBB201202010: 'comb' also for segm data
                            axis([min(t) max(t) -Inf Inf])
                            set(pl,'color',colors{mod(al-1,7)+1}) %al has 4 colors, should start over with blue after 7 lines
                            if names==0
                                title(['Segm. [' num2str(p1) '], dim. [' num2str(p2) '] - eucl'])
                                st{al} = ['Segm. ' num2str(p1(k)) ', dim. ' num2str(p2(m)) ];
                            elseif names==1
                                title(['Segm. [' num2str(p1) '], dim. [' num2str(p2) '] - eucl'])
                                st{al} = ['Segm. ' char(d.segmentName{p1(k)}) ', dim. ' num2str(p2(m)) ];
                            end
                            al=al+1;
                            hold on
                        end
                        if ~isscalar(label) %if label is [] or string, then plot labels
                            if strcmp('sec',timetype)
                                xlabel('seconds')
                            else xlabel('frames')
                            end
                            if ~isempty(label)
                                ylabel(label)
                            end
                        end
                    end
                elseif strcmp(var, 'quat')
                    for m=1:length(p2)
                        if strcmp(plotopt, 'sep')
                            if strcmp(plotarr, 'h')
                                subplot(length(p2), length(p1), length(p2)*(k-1)+m)
                            else subplot(length(p1), length(p2), length(p2)*(k-1)+m)
                            end
                            plot(t, tmp(:,p2(m)))
                            if names==0
                                title(['Segm. ' num2str(p1(k)) ', comp. ' num2str(p2(m)) ' - quat']);
                            elseif names==1
                                title(['Segm. ' char(d.segmentName{p1(k)}) ', comp. ' num2str(p2(m)) ' - quat'])
                            end
                            axis([min(t) max(t) -Inf Inf])
                        else
                            pl=plot(t, tmp(:,p2(m))); %FIXBB201202010: 'comb' also for segm data
                            axis([min(t) max(t) -Inf Inf])
                            set(pl,'color',colors{mod(al-1,7)+1}) %al has 4 colors, should start over with blue after 7 lines
                            if names==0
                                title(['Segm. [' num2str(p1) '], comp. [' num2str(p2) '] - quat'])
                                st{al} = ['Segm. ' num2str(p1(k)) ', comp. ' num2str(p2(m)) ];
                            elseif names==1
                                title(['Segm. [' num2str(p1) '], comp. [' num2str(p2) '] - quat'])
                                st{al} = ['Segm. ' char(d.segmentName{p1(k)}) ', comp. ' num2str(p2(m)) ];
                            end
                            al=al+1;
                            hold on
                        end
                        if ~isscalar(label) %if label is [] or string, then plot labels
                            if strcmp('sec',timetype)
                                xlabel('seconds')
                            else xlabel('frames')
                            end
                            if ~isempty(label)
                                ylabel(label)
                            end
                        end
                    end
                end
            else
                disp([10, 'No data to be plotted.', 10])
            end
        end
    end
    if strcmp(plotopt, 'comb') %plot legend
        legend(st, 'Location', 'EastOutside');
    end

else % direct reference to data
    if ~exist('p1')
        p1=1;
    end
    d=d(:);
    plot(d(:,p1));
end
hold off


function m=name2number(d, marker)
m=[];


for i=1:length(marker)
    if isfield(d,'markerName') %mocap or norm structure
        for j=1:length(d.markerName)
            if strcmp(char(marker{i}),char(d.markerName{j}))
                m=[m,j];
            end
        end
    elseif isfield(d,'segmentName') %segment structure
        for j=1:length(d.segmentName)
            if strcmp(char(marker{i}),char(d.segmentName{j}))
                m=[m,j];
            end
        end
    end
end

if length(m)<length(marker)
    x=length(marker)-length(m);
    str=sprintf([10 '%d marker(s) not matching with marker names in the given MoCap Structure.', x, 10]);
    disp([10, str, 10])
end
