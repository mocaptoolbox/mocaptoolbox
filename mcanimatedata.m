function mcanimatedata(d,p,optionsData,optionsSR,optionsVisual,optionsLabel,optionsTicks)
% Creates an animation of both mocap data and plots or images of time series data. The function supports up to four sets of uni- or multivariate time series; each of these can be placed above, below, to the left, or to the right of the mocap data animation.
%
% syntax
%
% mcanimatedata(d,p,dataLocation,data)
%
% mcanimatedata(___, Name,Value)
%
% input parameters
%
% d: MoCap data structure
% p: animpar structure (optional)
% dataLocation: location of the time series with respect to the mocap data animation ('north' | 'south' | 'east' | 'west')
% data: uni- or multivariate (time by dimension) time series
% ___SampleRate: E.g., mcanimatedata(...,'northSampleRate',60). Sample rate (in Hz) of the time series data, set by default to Mocap data sample rate
% ___PlotType: Type of plot to use to display the time series data. Either 'line' (default) or 'image'.
% windowType: Type of window to display the time series data. Either 'sliding' (default) or hopping window
% ___windowLength: length of the window (in frames) to display the time series data. Default: 100
% ___LinePlotColor: Line color(s) for creating line plots (___plotType,'Line'), either specified as a character array, a string array, or a N-by-3 RGB colors array. Default: color set for marker number colors in animpar structure (or in mcinitanimpar if p has not been specified).
% ___YLabel: Labels the y-axis of the time series data (optional)
% showYTicks: adds y-axis ticks to all sets of time series data. It can be used to indicate, when creating line plots, minima and maxima of time series data (optional). Either 'off' (default) or 'on'
% ___YTicks: Sets y-axis tick values (optional). Ticks need to be specified as a 1-by-N vector of increasing values.
% ___YTickLabels: Sets y-axis tick labels (optional). Specify labels as a cell array of character vectors or as a string array. If no y-axis tick values are specified and two tick labels are set, these will be assigned to minima and maxima in line plots.
%
% examples
%
% data = mcgetmarker(d,1).data;
% mcanimatedata(d,'south',data)
%
% mcanimatedata(d,p,'east',data,'eastLinePlotColor',{'r','y','g'})
%
% mcanimatedata(d,p,'west',data,'westYtickLabels',{'X','Y','Z'},'westPlotType','image')
%
% mcanimatedata(d,p,'north',data,'northPlotType','image','east',data(:,1),'windowType','hopping')
%
% mcanimatedata(d,p,'south',mctimeder(d).data,'southYtickLabels',{'slowest','fastest'})
%
% comments
%
% The Y axis direction for images is reversed (i.e., it goes from bottom to top) when plotting on north and south locations.
%
% see also
% mcanimate, mcplotframe, mcplot3Dframe, mcinitanimpar
    arguments
        d
        p = mcinitanimpar
        optionsData.north % data is expected to be time by dim
        optionsData.south
        optionsData.east
        optionsData.west
        optionsSR.northSampleRate
        optionsSR.southSampleRate
        optionsSR.eastSampleRate
        optionsSR.westSampleRate
        optionsVisual.northPlotType {mustBeMember(optionsVisual.northPlotType,["line","image"])} = 'line'
        optionsVisual.southPlotType {mustBeMember(optionsVisual.southPlotType,["line","image"])} = 'line'
        optionsVisual.eastPlotType {mustBeMember(optionsVisual.eastPlotType,["line","image"])} = 'line'
        optionsVisual.westPlotType {mustBeMember(optionsVisual.westPlotType,["line","image"])} = 'line'
        optionsVisual.windowType {mustBeMember(optionsVisual.windowType,["hopping","sliding"])} = "sliding"
        optionsVisual.northWindowLength = 100
        optionsVisual.southWindowLength = 100
        optionsVisual.eastWindowLength = 100
        optionsVisual.westWindowLength = 100
        optionsVisual.northLinePlotColor
        optionsVisual.southLinePlotColor
        optionsVisual.eastLinePlotColor
        optionsVisual.westLinePlotColor
        optionsLabel.northYLabel
        optionsLabel.southYLabel
        optionsLabel.eastYLabel
        optionsLabel.westYLabel
        optionsTicks.showYTicks {mustBeMember(optionsTicks.showYTicks,["off","on"])}
        optionsTicks.northYTicks (1,:) {mustBeNumeric} % note that this function uses pcolor(), so nticks == nrows+1
        optionsTicks.southYTicks (1,:) {mustBeNumeric}
        optionsTicks.eastYTicks (1,:) {mustBeNumeric}
        optionsTicks.westYTicks (1,:) {mustBeNumeric}
        optionsTicks.northYTickLabels % if two labels are specified and no yticks are defined, the function labels extreme ticks
        optionsTicks.southYTickLabels
        optionsTicks.eastYTickLabels
        optionsTicks.westYTickLabels
    end
% color management (compatibility): convert old string color definition into num array [BB20111031]
    if ischar(p.colors)
        colors=NaN(5,3);
        for k=1:5
            colors(k,:)=lookup_l(p.colors(k));
        end
    else colors=p.colors; %Fix BB20141202 ? if colors were already in num array
    end
    bgcol=colors(1,:); % set background color
    f = fieldnames(optionsData);
    initfreq = d.freq;
    d = mcresample(d, p.fps);
    for k = 1:numel(f)
        dtemp = d;
        dtemp.data = optionsData.(f{k});
        if isfield(optionsSR,([f{k} 'SampleRate']))
            dtemp.freq = optionsSR.([f{k} 'SampleRate']);
        else
            dtemp.freq = initfreq;
        end
        dtemp = mcresample(dtemp, p.fps);
        optionsData.(f{k}) = dtemp.data;
    end
    if isempty(p.limits)
        % find ranges of coordinates
        x = reshape(d.data(:,1:3:end),[],1); tmp=x(:); maxx=max(tmp(find(~isnan(tmp)))); minx=min(tmp(find(~isnan(tmp))));
        y = reshape(d.data(:,2:3:end),[],1); tmp=y(:); maxy=max(tmp(find(~isnan(tmp)))); miny=min(tmp(find(~isnan(tmp))));
        z = reshape(d.data(:,3:3:end),[],1); tmp=z(:); maxz=max(tmp(find(~isnan(tmp)))); minz=min(tmp(find(~isnan(tmp))));
        midx = (maxx+minx)/2;
        midy = (maxy+miny)/2;
        midz = (maxz+minz)/2;

        scrratio = p.scrsize(1)/p.scrsize(2);
        range = max((maxx-minx)/scrratio, maxz-minz)/2;
        zrange = (maxy-miny)/2;
        % axis limits for plot
        p.limits = [midx-scrratio*1.2*range midx+scrratio*1.2*range midz-1.2*range midz+1.2*range];
    end
    minxx = p.limits(1);
    maxxx = p.limits(2);
    minzz = p.limits(3);
    maxzz = p.limits(4);
    if strcmp(p.videoformat,'avi')
        v = VideoWriter(p.output); %set file name
    else
        v = VideoWriter(p.output,'MPEG-4'); %BBADD20150717
    end
    v.FrameRate=p.fps;
    open(v);
    ii = ones(size(f));
    winNum = ones(size(f));
    if p.visible==0
        disp('Creating animation, please wait...');
    end
    if isfield(p,'background') & ~isempty(p.background);
        [~,~,fEXT]=fileparts(p.background);
        if matches(upper(fEXT),{'.AVI', '.MJ2', '.MPG', '.WMV', '.CUR', '.ASF', '.ASX', '.MP4', '.M4V','.MOV','.OGG'})
            vidr = VideoReader(p.background);
        end
    end
    for k = 1:size(d.data,1)
        ptemp=p;
        ptemp.showfnum=0;
        ptemp.visible=0;
        mcplotframe(d,k,ptemp);
        if isfield(p,'background') & ~isempty(p.background);
            hold on
            if matches(upper(fEXT),{'.GIF', '.PGM', '.PBM', '.PPM', '.CUR', '.ICO', '.TIF', '.SVS', '.HDF4','.PNG','.BMP','.TIFF','.JPEG','.JPG','.RAS','.SVS'})
                Img = imread(p.background);
                hh = image([minxx maxxx],[maxzz minzz],Img);
            elseif exist('vidr','var')
                Img = readFrame(vidr);
            % hh = image([minxx maxxx],[maxzz minzz],Img); <- this will resize the video to fill the entire figure
            hh = image([1 vidr.Width],[vidr.height,1],Img);
            end

            uistack(hh,'bottom')
            uistack(hh,'up',1)
            drawnow
            hold off
        end
        ax1=gca;
        fg = figure(2);
        if p.visible==0
            fg.Visible='Off';
        end
        hold on
        tcl=tiledlayout(1,1); %create subplots
        ax1.Parent=tcl;
        ax1.Layout.Tile=1;
        close(1)
        set(gcf,'color',bgcol);
        view(0,90);
        if p.showfnum==1
            t = text(0,0,num2str(k));
            t.Color=colors(5,:);
        end
        for j = 1:numel(f) %for each data set
            if (isfield(optionsTicks,[f{j} 'YTicks']) | isfield(optionsTicks, [f{j} 'YTickLabels'])) & ~isfield(optionsTicks, 'showYTicks');
                optionsTicks.([f{j} 'ShowYTicks'])="on";
            elseif ~isfield(optionsTicks, 'showYTicks')
                optionsTicks.([f{j} 'ShowYTicks'])="off";
            elseif isfield(optionsTicks, 'showYTicks')
                if optionsTicks.showYTicks=="on"
                    optionsTicks.([f{j} 'ShowYTicks'])="on";
                else
                    optionsTicks.([f{j} 'ShowYTicks'])="off";
                end
            end

            if isfield(optionsVisual,[f{j} 'LinePlotColor']) && ~isnumeric(optionsVisual.([f{j} 'LinePlotColor']))
                optionsVisual.([f{j} 'LinePlotColor']) = convertCharsToStrings(optionsVisual.([f{j} 'LinePlotColor']));
            end
            nexttile(f{j})
            winLen(j) = optionsVisual.([f{j} 'WindowLength']);
            dd{j} = optionsData.(f{j});
            if isvector(dd{j})
                dd{j} = dd{j}(:);
            end
            if optionsVisual.windowType == "sliding"
                dd{j} = [NaN(winLen(j)-1,size(dd{j},2));dd{j}];
                curWin{j} = winFun(dd{j},winLen(j),k,optionsVisual.windowType);
                if optionsVisual.([f{j} 'PlotType']) == "line"
                    plt=plot(1:size(curWin{j},1),curWin{j},'Color',colors(5,:));
                    if isfield(optionsVisual,[f{j} 'LinePlotColor'])
                        for kkk=1:numel(plt)
                            if isvector(optionsVisual.([f{j} 'LinePlotColor']))
                                plt(kkk).Color=optionsVisual.([f{j} 'LinePlotColor'])(kkk);
                            else
                                plt(kkk).Color=optionsVisual.([f{j} 'LinePlotColor'])(kkk,:);
                            end
                        end
                    end
                elseif optionsVisual.([f{j} 'PlotType']) == "image"
                    [nr,nc] = size(curWin{j}');
                    if strcmpi(f{j},'east') | strcmpi(f{j},'west')
                    pcl = pcolor([flipud(curWin{j}') nan(nr,1); nan(1,nc+1)]);
                    else
                    pcl = pcolor([curWin{j}' nan(nr,1); nan(1,nc+1)]);
                    end
                    shading flat;
                    set(gca, 'ydir', 'reverse');
                    caxis([min(dd{j}(:)), max(dd{j}(:))])
                end
                hold on
                if optionsVisual.([f{j} 'PlotType']) == "line"
                    plt=plot(size(curWin{j},1),curWin{j}(end,:),'o','Color',colors(5,:),'MarkerEdgeColor','none','MarkerFaceColor',colors(5,:));
                    if isfield(optionsVisual,[f{j} 'LinePlotColor'])
                        for kkk=1:numel(plt)
                            if isvector(optionsVisual.([f{j} 'LinePlotColor']))
                                plt(kkk).MarkerFaceColor=optionsVisual.([f{j} 'LinePlotColor'])(kkk);
                            else
                                plt(kkk).MarkerFaceColor=optionsVisual.([f{j} 'LinePlotColor'])(kkk,:);
                            end
                        end
                    end
                end
            elseif optionsVisual.windowType == "hopping"
                if ii(j) == 1
                    if size(dd{j},1) < winNum(j)*winLen(j)
                        dd{j} = [dd{j};NaN(winNum(j)*winLen(j)-size(dd{j},1),size(dd{j},2))];
                    end
                    curWin{j} = winFun(dd{j},winLen(j),winNum(j),optionsVisual.windowType);
                end
                if optionsVisual.([f{j} 'PlotType']) == "line"
                    plt=plot(1:size(curWin{j},1),curWin{j},'Color',colors(5,:));
                    if isfield(optionsVisual,[f{j} 'LinePlotColor'])
                        for kkk=1:numel(plt)
                            if isvector(optionsVisual.([f{j} 'LinePlotColor']))
                                plt(kkk).Color=optionsVisual.([f{j} 'LinePlotColor'])(kkk);
                            else
                                plt(kkk).Color=optionsVisual.([f{j} 'LinePlotColor'])(kkk,:);
                            end
                        end
                    end
                elseif optionsVisual.([f{j} 'PlotType']) == "image"
                    [nr,nc] = size(curWin{j}');
                    if strcmpi(f{j},'east') | strcmpi(f{j},'west')
                        pcl = pcolor([flipud(curWin{j}') nan(nr,1); nan(1,nc+1)]);
                    else
                        pcl = pcolor([curWin{j}' nan(nr,1); nan(1,nc+1)]);
                    end
                    shading flat;
                    set(gca, 'ydir', 'reverse');
                    caxis([min(dd{j}(:)), max(dd{j}(:))])
                end
                hold on
                if optionsVisual.([f{j} 'PlotType']) == "line"
                    plt=plot(ii(j),curWin{j}(ii(j),:),'o','Color',colors(5,:),'MarkerEdgeColor','none','MarkerFaceColor',colors(5,:));
                    if isfield(optionsVisual,[f{j} 'LinePlotColor'])
                        for kkk=1:numel(plt)
                            if isvector(optionsVisual.([f{j} 'LinePlotColor']))
                                plt(kkk).MarkerFaceColor=optionsVisual.([f{j} 'LinePlotColor'])(kkk);
                            else
                                plt(kkk).MarkerFaceColor=optionsVisual.([f{j} 'LinePlotColor'])(kkk,:);

                            end
                        end
                    end
                elseif optionsVisual.([f{j} 'PlotType']) == "image"
                    plot(ii(j),1,'o','Color',colors(5,:),'MarkerEdgeColor','none','MarkerFaceColor',colors(5,:));
                end
                if ii(j) < winLen(j)
                    ii(j) = ii(j)+1;
                else
                    ii(j) = 1;
                    winNum(j) = winNum(j)+1;
                end
            end
            if strcmpi(f{j},'east') | strcmpi(f{j},'west')
                camroll(90);
                set(gca, 'YDir', 'reverse' )
            end
            if optionsVisual.([f{j} 'PlotType']) == "line"
                xlim([1,size(curWin{j},1)]);
                ylim([min(dd{j}(:)), max(dd{j}(:))]);
            end
            set(gca,'xtick',[]);
            set(gca,'xticklabel',[])
            if optionsTicks.([f{j} 'ShowYTicks'])=="off"
                set(gca,'ytick',[]);
                set(gca,'yticklabel',[])
            end
            set(gca,'color',bgcol)
            if optionsTicks.([f{j} 'ShowYTicks'])=="off"
                set(gca,'XColor', bgcol,'YColor',bgcol)
            else
                if optionsTicks.([f{j} 'ShowYTicks'])=="on" & optionsVisual.([f{j} 'PlotType']) == "line" & ~isfield(optionsTicks, [f{j} 'YTickLabels']) & ~isfield(optionsTicks,[f{j} 'YTicks'])
                    yticks(ylim);
                elseif optionsTicks.([f{j} 'ShowYTicks'])=="on" & optionsVisual.([f{j} 'PlotType']) == "image" & ~isfield(optionsTicks, [f{j} 'YTickLabels']) & ~isfield(optionsTicks,[f{j} 'YTicks'])
                    yT = yticks;
                    yticks([yT(1)+.5 yT(end-1)+.5]);
                end
                set(gca,'TickDir','out')
                box off
                set(gca,'XColor', bgcol,'YColor',colors(5,:))
                if isfield(optionsTicks,[f{j} 'YTicks'])
                    if optionsVisual.([f{j} 'PlotType']) == "image"
                        if strcmpi(f{j},'east') | strcmpi(f{j},'west')
                            yticks(optionsTicks.([f{j} 'YTicks']));
                        else
                            ax=gca;
                            yticks(sort(ax.YLim(end)-optionsTicks.([f{j} 'YTicks']))+ax.YLim(1));
                        end
                    else
                        yticks(optionsTicks.([f{j} 'YTicks']))
                    end
                else
                    ax=gca;
                    if isfield(optionsTicks, [f{j} 'YTickLabels']) & numel(optionsTicks.([f{j} 'YTickLabels'])) == 2
                    yticks(ax.YLim);
                    end
                    yT = yticks;
                end
                if isfield(optionsTicks, [f{j} 'YTickLabels'])
                    if ~isfield(optionsTicks,[f{j} 'YTicks']) & optionsVisual.([f{j} 'PlotType']) == "image"
                        if numel(optionsTicks.([f{j} 'YTickLabels'])) > numel(yticks)
                            yT = 1:numel(optionsTicks.([f{j} 'YTickLabels']));
                        else
                            yT = yticks;
                        end
                        if numel(yT) == 2
                            yT = [yT(1)+.5 yT(end)-.5];
                        else
                            yT=yT(1:end)+.5;
                        end
                        yticks(yT);
                    end
                    ytLabels = (optionsTicks.([f{j} 'YTickLabels']));
                    ytLabels = ytLabels(:);
                    if strcmpi(f{j},'east') | strcmpi(f{j},'west')
                        if isfield(optionsTicks,[f{j} 'YTicks'])
                            yticklabels(ytLabels)
                        else
                            if optionsVisual.([f{j} 'PlotType']) == "image"
                                yticklabels(ytLabels)
                            else
                                yticklabels(optionsTicks.([f{j} 'YTickLabels']))
                            end
                        end
                    elseif strcmpi(f{j},'north') | strcmpi(f{j},'south')
                        if optionsVisual.([f{j} 'PlotType']) == "image"
                            if nr > numel(ytLabels) & ~isfield(optionsTicks,[f{j} 'YTicks'])
                                yticks(sort(nr-(0:nr-1)+.5))
                                yticklabels([repmat({' '},nr-numel(ytLabels),1); wrev(ytLabels)])
                            elseif nr > numel(ytLabels) & isfield(optionsTicks,[f{j} 'YTicks'])
                                yticklabels(wrev(ytLabels))
                            else
                                yticklabels(wrev(ytLabels))
                            end
                        else
                            yticklabels(ytLabels)
                        end
                    end
                else
                    if ~isfield(optionsTicks,[f{j} 'YTicks'])
                        if optionsVisual.([f{j} 'PlotType']) == "image"
                            if strcmpi(f{j},'north') | strcmpi(f{j},'south')
                                yTickLabels = string([yT(end) yT(1)]);
                                yticklabels(yTickLabels);
                            elseif strcmpi(f{j},'east') | strcmpi(f{j},'west')
                                yTickLabels = string([yT(1) yT(end)]);
                                yticklabels(yTickLabels);
                            end
                        end
                    else
                        if optionsVisual.([f{j} 'PlotType']) == "image"
                            if strcmpi(f{j},'north') | strcmpi(f{j},'south')
                                yticklabels(wrev(optionsTicks.([f{j} 'YTicks'])));
                            elseif strcmpi(f{j},'east') | strcmpi(f{j},'west')
                                yTickLabels = string(yticks);
                                yticklabels(yTickLabels);
                            end
                        end
                    end
                end
                if optionsTicks.([f{j} 'ShowYTicks'])=="on" & optionsVisual.([f{j} 'PlotType']) == "line" & ~isfield(optionsTicks, [f{j} 'YTickLabels']) & ~isfield(optionsTicks,[f{j} 'YTicks'])
                    % round in a display-friendly manner
                    lims = ylim;
                    [yl1 yl2] = deal(lims(1),lims(2));
                    flag = 1;
                    kk = 0;
                    while flag
                        roundres = round([yl1,yl2],kk);
                        if roundres(1)==roundres(2)
                            kk = kk+1;
                        else
                            flag = 0;
                        end
                    end
                    yticklabels(roundres);
                end
            end
            if isfield(optionsLabel,[f{j} 'YLabel'])
                yl = ylabel(optionsLabel.([f{j} 'YLabel']));
            end
            yl.Color=colors(5,:);
            if optionsVisual.windowType == "sliding"
                set(gca,'YAxisLocation','right')
            end
            if isfield(optionsData,'north') & isfield(optionsData,'east')
                if matches(f{j}, 'north')
                    set(gca,'YAxisLocation','left')
                end
                if isfield(optionsData,'west')
                   if matches(f{j}, 'west')
                       set(gca,'YAxisLocation','left')
                   end
                end

            end
        end
        frame = getframe(gcf);
        writeVideo(v,frame);
        if p.visible==0
            close(2)
        end
    end
    close(v)
end
function curWin = winFun(dd,wlen,k,method)
    if method == "sliding"
    curWin = dd((1:wlen)+(k-1),:); % sliding window
    elseif method == "hopping"
    curWin = dd(1+wlen*(k-1):wlen*k,:); % nonsliding window
    end
end
function colorar=lookup_l(colorstr)
    if strcmp(colorstr, 'k')
        colorar=[0 0 0];
    elseif strcmp(colorstr, 'w')
        colorar=[1 1 1];
    elseif strcmp(colorstr, 'r')
        colorar=[1 0 0];
    elseif strcmp(colorstr, 'g')
        colorar=[0 1 0];
    elseif strcmp(colorstr, 'b')
        colorar=[0 0 1];
    elseif strcmp(colorstr, 'y')
        colorar=[1 1 0];
    elseif strcmp(colorstr, 'm')
        colorar=[1 0 1];
    elseif strcmp(colorstr, 'c')
        colorar=[0 1 1];
    end
end
