function mcplottimeseries_dep(d, marker, dim, timetype, plotopt)
% Plots motion capture data as time series.
%
% syntax
% mcplottimeseries(d, marker) % for MoCap or norm data structure
% mcplottimeseries(d, marker, dim) % specifying dimensions to be plotted
% mcplottimeseries(d, marker, timetype) % sec or frames as axis unit
% mcplottimeseries(d, marker, plotopt) % combined or separate plots
% mcplottimeseries(d, marker, dim, timetype)
% mcplottimeseries(d, marker, dim, plotopt)
% mcplottimeseries(d, marker, dim, timetype, plotopt)
% mcplottimeseries(s, segm, var) % for segm data structure
% mcplottimeseries(s, segm, var, timetype) 
%
% input parameters
% d/s: MoCap data structure, norm data structure, or segm data structure
% marker: vector containing merker numbers to be plotted (for MoCap or norm data structure)
% segm: body segment number (for segm data structure)
% dim: vector containing dimensions to be plotted (for MoCap data structure)
% var: variable to be plotted for segment segm (for segm data structure)
% timetype: time type used in the plot (seconds (default) or 'frame')
% plotopt: plotting option (for MoCap or norm data structure); separate (default) or 'comb':
%   separate: all time series  are plotted in separate subplots
%   comb: all time series will be plotted into the same plot using different colors)
%
% output
% Figure.
%
% examples
% mcplottimeseries(d, 2) % MoCap or norm data structure, marker 2, first dim
% mcplottimeseries(d, 1:3, 3) % markers 1 to 3, third dim
% mcplottimeseries(d, 1:3, 3, 'comb') % same plot, different colors per dim
% mcplottimeseries(d, 5, 'frame') % frames as x axis unit
% mcplottimeseries(d, 5, 'frame', 'comb')
% mcplottimeseries(s, [3 6 20], 'angle') % for segm data structure
% mcplottimeseries(s, 5:10, 'eucl', 'frame') % frames as x axis unit
% mcplottimeseries(s, [12 14], 'quat')
% 
% comment
% For segment data, the plot option 'comb' is not implemented yet.
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

% rearrangement of input argument management: BB 20111015
if strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data')
    if nargin==4 
        if strcmp(timetype, 'comb') == 1
            plotopt=timetype;
            timetype='sec';
        else plotopt='sep'; %timetype='frame'
        end
        if strcmp(dim, 'frame') == 1
            timetype=dim;
            dim=1;
        end
    end
    if nargin==3
        if strcmp(dim, 'comb') == 1
            plotopt=dim;
            timetype='sec';
            dim=1;
        elseif strcmp(dim, 'frame') == 1
            timetype=dim;
            plotopt='sep';
            dim=1;
        else
            timetype='sec';
            plotopt='sep';
        end
    end
    if nargin<3
        dim=1;
        timetype='sec';
        plotopt='sep';
    end
    
elseif strcmp(d.type, 'segm data')
    if nargin==3
        timetype='sec';
    end
else
    disp([10, 'The first input argument should be a variable with MoCap, norm, or segm data structure.', 10]);
    return
end

if nargin<2
    disp([10, 'Please specify the markers (or segments) to be plotted.', 10])
    return
end

if max(marker)>d.nMarkers
    disp([10, 'Marker number out of range', 10]);
    return
end


p1=marker;
p2=dim;


colors={'blue', 'green', 'red', 'cyan', 'magenta', 'yellow', 'black'};

if isfield(d,'type')
    t = (1:d.nFrames)';%-1 taken away as it caused time series to start at 0... [BB 20110301]
    if strcmp(timetype,'sec') 
        t = t/d.freq; 
    end
    if strcmp(d.type, 'MoCap data')
        figure
        al=1;%amount of lines - for 'comb' plotting
        for k=1:length(p1)
            for m=1:length(p2)
                if strcmp(plotopt, 'sep')
                    subplot(length(p1), length(p2), length(p2)*(k-1)+m)
                    pl=plot(t, d.data(:,3*p1(k)-3+p2(m)));
                    axis([min(t) max(t) -Inf Inf])
                    title(['Marker [' num2str(p1(k)) '], dim. [' num2str(p2(m)) ']'])
                else
                    pl=plot(t, d.data(:,3*p1(k)-3+p2(m)));
                    axis([min(t) max(t) -Inf Inf])
                    title(['Marker [' num2str(p1) '], dim. [' num2str(p2) ']'])
                    set(pl,'color',colors{mod(al-1,7)+1}) %al has 4 colors, should start over with blue after 7 lines
                    st{al} = ['M. ' num2str(p1(k)) ', dim. ' num2str(p2(m))];
                    al=al+1;
                    hold on
                end
            end
        end
        if strcmp(plotopt, 'comb') %plot legend
            legend(st, 'Location', 'EastOutside'); 
        end 
    elseif strcmp(d.type, 'norm data')
        figure
        al=1;%amount of lines - for 'comb' plotting
        plot(t, d.data(:,p1));
        for k=1:length(p1)
            for m=1%:length(p2)
                if strcmp(plotopt, 'sep') 
                    subplot(length(p1), 1, k)
                    plot(t, d.data(:,p1(k)))
                    axis([min(t) max(t) -Inf Inf])
                    title(['Marker [' num2str(p1(k)) '], norm data'])
                else
                    pl=plot(t, d.data(:,p1(k))); %FIXBB110102: 'comb' also for norm data
                    axis([min(t) max(t) -Inf Inf])
                    title(['Marker [' num2str(p1) '], norm data'])
                    set(pl,'color',colors{mod(al-1,7)+1}) %al has 4 colors, should start over with blue after 7 lines
                    st{al} = ['M. ' num2str(p1(k))];
                    al=al+1;
                    hold on
                end
            end
        end
        if strcmp(plotopt, 'comb') legend(st, 'Location', 'EastOutside'); end %plot legend
    
    elseif strcmp(d.type, 'segm data')
        tmp=[];
        for k=1:length(p1)
            tmp = getfield(d.segm(p1(k)),p2);
            if ~isempty(tmp)
                if strcmp(p2, 'angle')
                    % k
                    subplot(length(p1),1,k)
                    plot(t, tmp)
                    title(['Segm. ' num2str(p1(k))])
                elseif strcmp(p2, 'eucl')
                    for m=1:3
                        subplot(length(p1), 3, 3*(k-1)+m)
                        plot(t, tmp(:,m)), title(['Segm. ' num2str(p1(k)) ' Dim. ' num2str(m)]);
                        axis([min(t) max(t) -Inf Inf])
                    end
                elseif strcmp(p2, 'quat')
                    for m=1:4
                        subplot(length(p1), 4, 4*(k-1)+m)
                        plot(t, tmp(:,m)), title(['Segm. ' num2str(p1(k)) ' Comp. ' num2str(m)]);
                        axis([min(t) max(t) -Inf Inf])
                    end
                end
            else
                disp('No data to be plotted.')
            end
        end
    end
else % direct reference to data
    if ~exist('p1')
        p1=1;
    end
    d=d(:);
    plot(d(:,p1));
end
hold off
