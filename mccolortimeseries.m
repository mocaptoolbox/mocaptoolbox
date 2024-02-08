function mapar2 = mccolortimeseries(d,mapar,options,vectorOptions,matrixOptions,otherOptions)
%
% Attaches a color time series to a MoCap animation parameter structure, allowing marker and/or connectors to change their colors over time in animations.
%
% syntax
% par2 = mccolortimeseries(d, par);
% par2 = mccolortimeseries(__, Name, Value); % specifies options using one or more name-value pair arguments in addition to the input arguments in the previous syntax
%
%
% input parameters
% d: Values to be mapped into colors or the color values themselves. d can be:
% - a norm data structure
% - a matrix containing values to be mapped into colors for each marker
% - a vector containing shared values to be mapped into colors across markers (requires specifying the number of target markers via option 'nMarkers')
% - a tensor (time x RGB channel x marker) containing RGB color values for each timepoint and marker
% - a matrix (time x RGB channel) containing shared RGB color values across markers for each time point (requires setting option 'RGB' to 1 and specifying the number of target markers via option 'nMarkers')
% - a vector containing shared HEX color values across markers for each time point (requires setting option 'Hex' to 1 and specifying the number of target markers via option 'nMarkers').
% p: animpar structure
% Name-value arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%  type: specify whether to assign colors to markers ('markers'), connectors ('connectors'), or both ('both'). Connectors are assigned colors based on the mean value assigend to their two corresponding markers. Default: 'markers'
%  colormap: name of the MATLAB colormap to be used, either specified as a character array or a string array. When d contains color values, this option is ignored. Default: 'jet'
%  mappingtype: Set all markers to have the same color map scale ('all') or or to have different scales ('independent'). Default: 'all'
%  Hex: Used to specify whether HEX color values are used when d is an input vector (0 | 1). Default value is 0, meaning that the values of d are meant to be mapped into colors.
%  RGB: Used to specify whether RGB color values are used when d is a matrix (0 | 1). Default value is 0, meaning that the values of d are meant to be mapped into colors.
%
% output
% par: animpar structure used for plotting or animating a MoCap data structure
%
% examples
%
% load('mcdemodata','dance1','mapar')
% vel = mctimeder(dance1);
% nvel = mcnorm(vel);
% mapar2 = mccolortimeseries(nvel,mapar,mappingtype='independent',colormap='parula');
% mcanimate(dance1,mapar2);
%
% m = randn(dance1.nFrames,dance1.nMarkers);
% mapar3 = mccolortimeseries(m,mapar,mappingtype='independent',colormap=prism);
% mcanimate(dance1,mapar3);
%
% v = log2(1:dance1.nFrames)';
% mapar4 = mccolortimeseries(v,mapar,colormap=hsv,nMarkers=dance1.nMarkers,type='connectors');
% mcanimate(dance1,mapar4);
%
% t = abs(randn(dance1.nFrames,3,dance1.nMarkers));
% t = t./max(t,[],'all');
% mapar5 = mccolortimeseries(t,mapar,nMarkers=dance1.nMarkers,type='both');
% mcanimate(dance1,mapar5);
%
% m2 = repmat(linspace(0,1,dance1.nFrames)',1,3);
% mapar6 = mccolortimeseries(m2,mapar,nMarkers=dance1.nMarkers,type='connectors',RGB=1);
% mcanimate(dance1,mapar6);
%
% v2 = repmat({'#FFFF00';'#FF0000'},dance1.nFrames,1);
% mapar7 = mccolortimeseries(v2,mapar,nMarkers=dance1.nMarkers,type='both',Hex=1);
% mapar7.fps = dance1.freq;
% mcanimate(dance1,mapar7);
%
% comments
%
%
% see also
% mcplotframe, mcanimate, mcanimatedata
%
    arguments
        d % either provided or coming from a mocap (norm) struct
        mapar
        options.type = 'markers'%,'connectors','both'
        options.colormap = 'jet'
        options.mappingtype = 'all' % either each marker has its own max and min, or there is max and min for the whole set
        vectorOptions.Hex matlab.lang.OnOffSwitchState = 0
        matrixOptions.RGB matlab.lang.OnOffSwitchState = 0
        otherOptions.nMarkers {mustBePositive, mustBeInteger}
    end
    if (~isstruct(d) && (isvector(d) || (ismatrix(d) && matrixOptions.RGB)) && isempty(otherOptions.nMarkers))
        error('Specify the number of markers of your target MoCap data structure. Example: mccolortimeseries(d, par, nMarkers=28) ')
    end
    mapFlag = 'no';
    if isfield(d,'type') && strcmp(d.type, 'norm data')
        data = d.data;
        mapFlag = 'yes';
    end
    if ~isstruct(d) && ismatrix(d) && ~matrixOptions.RGB && ~vectorOptions.Hex
        data = d;
        mapFlag = 'yes';
    end
    if ~isstruct(d) && isvector(d) && ~vectorOptions.Hex
        d = d(:);
        data = repmat(d,1,otherOptions.nMarkers);
        mapFlag = 'yes';
    end
    mapar2=mapar;
    if mapFlag == "yes";
        figure
        cmap = colormap(options.colormap);
        close
        if options.mappingtype == "independent"
            % option 1: each marker is independent
            % markers
            for k = 1:width(data)
                m = data(:,k);
                ran=range(m); %finding range of data
                min_val=min(m);%finding maximum value of data
                max_val=max(m);%finding minimum value of data
                y(:,k)=floor(((m-min_val)/ran)*(height(cmap)-1))+1;
                for i=1:height(m)
                    a=y(i,k);
                    mcol(i,:,k)=cmap(a,:);
                end
            end
            % now we need to assign markers to connections
            % mean across markers for each connector
            for k = 1:height(mapar.conn) % for each connection
                for i=1:height(m)
                    a=[y(i,mapar.conn(k,1)) y(i,mapar.conn(k,2))];
                    ccol(i,:,k)=mean(cmap(a,:));
                end
            end
        elseif options.mappingtype == "all"
            % option 2: a common max and min for the whole marker set
            % markers
            m = data(:);
            ran=range(m); %finding range of data
            min_val=min(m);%finding maximum value of data
            max_val=max(m);%finding minimum value of data
            for k = 1:width(data)
                m = data(:,k);
                y(:,k)=floor(((m-min_val)/ran)*(height(cmap)-1))+1;
                for i=1:height(m)
                    a=y(i,k);
                    mcol(i,:,k)=cmap(a,:);
                end
            end
            for k = 1:height(mapar.conn) % for each connection
                for i=1:height(m)
                    a=[y(i,mapar.conn(k,1)) y(i,mapar.conn(k,2))];
                    ccol(i,:,k)=mean(cmap(a,:));
                end
            end
        end
    end
    if ndims(d) == 3
        mcol = d;
    elseif ~isstruct(d) && isvector(d) && vectorOptions.Hex
        d = hex2rgb(d);
    end
    if ~isstruct(d) && ismatrix(d) && (matrixOptions.RGB || vectorOptions.Hex)
        mcol = repmat(d,1,1,otherOptions.nMarkers);
    end
    if mapFlag == "no"; % take the average of two colors to make the connector colors
        for k = 1:height(mapar.conn) % for each connection
            rgb1 = mcol(:,:,mapar.conn(k,1));
            rgb2 = mcol(:,:,mapar.conn(k,2));
            newcol = @(rgb1,rgb2) [sqrt((rgb1(:,1).^2+rgb2(:,1).^2)/2),sqrt((rgb1(:,2).^2+rgb2(:,2).^2)/2),sqrt((rgb1(:,3).^2+rgb2(:,3).^2)/2)];
            ccol(:,:,k)=newcol(rgb1,rgb2);
        end
    end
    if options.type == "both"
    mapar2.markercolors = mcol;
    mapar2.conncolors = ccol;
    elseif options.type == "markers"
    mapar2.markercolors = mcol;
    elseif options.type == "connectors"
    mapar2.conncolors = ccol;
    end
end
