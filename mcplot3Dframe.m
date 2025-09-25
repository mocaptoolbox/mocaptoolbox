function par = mcplot3Dframe(d, n, p)
% Plots frames of motion capture data in 3D.
%
% syntax
% par = mcplot3Dframe(d, n);
% par = mcplot3Dframe(d, n, p);
%
% input parameters
% d: MoCap data structure
% n: vector containing the numbers of the frames to be plotted
% p: animpar structure (optional)
%
% output
% par: animpar structure used for plotting the frames (if color strings were used, they will converted to RGB triplets)
%
% examples
% par = mcplot3Dframe(d, 1);
% mcplot3Dframe(d, 500:10:600, par);
%
% comments
% If the animpar structure is not given, the function calls
% mcinitanimpar with '3D' argument and sets the par3D.limits field of
% the animpar structure automatically so that all the markers fit into
% all frames.
%
% If the joint animation parameter field par3D.jointrotations is set to 1, mcplot3Dframe draws axes in each joint to represent rotations with respect to the global coordinate system defined in calibration (for data imported from Qualysis + Theia 3D markerless pose estimation)
%
% see also
% mcplotframe, mcanimate, mcanimatedata, mcinitanimpar, mcplayer
%
% Based on mcplotframe in the Motion Capture Toolbox,
% 3D version developed by Kristian Nymoen, University of Oslo
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland


par=[];

if isfield(d,'type') && strcmp(d.type, 'MoCap data') || isfield(d,'type') && strcmp(d.type, 'norm data') || isfield(d,'type') && strcmp(d.type, 'segm data')
else
    disp([10, 'The first input argument has to be a variable with valid mocap toolbox data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end


if nargin<3
    p = mcinitanimpar('3D');
    p.el = 10; %these values work better in 3D than the defaults for 2D
    p.az = 50; %these values work better in 3D than the defaults for 2D
    if nargin==1 || ~isnumeric(n) %output fix [BB20111031]
        disp([10, 'Please set frame number(s) you want to plot.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

for k=1:length(n)
    n1=n(k);
    if n1>d.nFrames
        w1=sprintf('Indicated frame(s) (%d) exceeds number of frames in data (%d).', max(n), d.nFrames);
        disp([10, w1, 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end


if isfield(p,'type') && strcmp(p.type, 'animpar')
else
    disp([10, 'The third input argument has to be an animation parameter structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if p.animate && p.getparams==0 %BBADd0150303
    currdir = cd; % store current directory
    if p.createframes==1
        mkdir(p.output) %BB20150507 in case frames (series of png files) are needed, and not video file
        cd(p.output)
    elseif p.createframes==2 %MH20201201 (animated gif)
        fn=[p.output '.gif'] ;
    else %VideoWriter is used with video file output %BB20150507
        fn=p.output; %BB_NEW_20140212 for VideoWriter
        if strcmp(p.videoformat,'avi')
            movObj = VideoWriter(fn); %set file name
        else
            movObj = VideoWriter(fn,'MPEG-4'); %BBADd0150717
        end
        movObj.FrameRate = p.fps; %set frame rate before opening the video object
        open(movObj); %open the object
    end

end

par=p;

% color management (compatibility): convert old string color definition into num array [BB20111031]
if ischar(p.colors)
    colors=NaN(5,3);
    for k=1:5
        colors(k,:)=lookup_l(p.colors(k));
    end
else
    colors=p.colors; %Fix BB20141202 ? if colors were already in num array
end

bgcol=colors(1,:); % set background color

if isfield(p,'markercolors') && ~isempty(p.markercolors) %field and colors are set
    if ischar(p.markercolors) % but in string format
        mcol=NaN(d.nMarkers,3);
        for k=1:size(p.markercolors,2)
            mcol(k,:)=lookup_l(p.markercolors(k));%convert to num array
        end
    else
        mcol=p.markercolors; %field and colors are set in num format already
    end
    if d.nMarkers > length(p.markercolors)
        for k=length(p.markercolors)+1:d.nMarkers
            mcol(k,:)=colors(2,:);
        end
    end
else %no field or/and empty
    mcol=repmat(colors(2,:),d.nMarkers,1);
end

if isfield(p,'conncolors') && ~isempty(p.conncolors) %field and colors are set
    if ischar(p.conncolors) % but in string format
        ccol=NaN(size(p.conn,1),3);
        for k=1:size(p.conncolors,2)
            ccol(k,:)=lookup_l(p.conncolors(k));%convert to num array
        end
    else
        ccol=p.conncolors; %field and colors are set in num format already
    end
    if size(p.conn,1) > length(p.conncolors)
        for k=length(p.conncolors)+1:size(p.conn,1)
            ccol(k,:)=colors(3,:);
        end
    end
else %no field or/and empty
    ccol=repmat(colors(3,:),size(p.conn,1),1);
end

%BBFIX 20120404: mcmerge problems
if p.trl~=0
    tcol=repmat(colors(4,:),d.nMarkers,1);
    if isfield(p,'tracecolors') && ~isempty(p.tracecolors) %(field and) tracecolors are set
        if ischar(p.tracecolors) % but in string format
            for k=1:size(p.tracecolors,2)
                tcol(k,:)=lookup_l(p.tracecolors(k));%convert to num array
            end
        else
            tcol(1:size(p.tracecolors,1),:)=p.tracecolors; %tracecolors in num format already
        end
    end
    if isempty(p.trm)
        p.trm=1:d.nMarkers; %plot all traces if trm is empty
    else
        if length(p.trm)<d.nMarkers
            %sort p.tracecolors/tcol1 according to p.trm
            %increase p.trm to have same length as d.nMarkers and fill it up with NaNs
            tmp=repmat(colors(4,:),d.nMarkers,1);
            tmp1=nan(d.nMarkers,1)';
            for k=1:length(p.trm)
                tmp(p.trm(k),:)=tcol(k,:);
                tmp1(p.trm(k))=p.trm(k);
            end
            tcol=tmp;
            p.trm=tmp1;
        end
    end
else
    tcol=[];
    p.trm=[];
end
p.tracecolors=tcol;

if ~isempty(p.trm)%created problem when merging and translating...
    p.trm=p.trm(:);
end

%warning if trace length is empty, but marker trace vector is set
if (p.trl==0 && ~isempty(p.trm)) || (p.trl==0 && ~isempty(p.tracecolors))
    disp([10, 'Warning: Please set trace length (trl) in your animation parameters in order to plot traces.', 10])
end

%if trace length is set, but vector indicating the markers to be traced is empty, all markers will be trace
if p.trl~=0 && isempty(p.trm)
    disp([10, 'Note: All markers traced.', 10])
    p.trm=1:d.nMarkers;
end


%BBFIX20120404: mcmerge problems
if p.showmnum==1
    ncol=repmat(colors(5,:),d.nMarkers,1);
    if isfield(p,'numbercolors') && ~isempty(p.numbercolors) %(field and) numbercolors are set
        if ischar(p.numbercolors) % but in string format
            for k=1:size(p.numbercolors,2)
                ncol(k,:)=lookup_l(p.numbercolors(k));%convert to num array
            end
        else
            ncol(1:size(p.numbercolors,1),:)=p.numbercolors; %numbercolors in num format already
        end
    end
    if isempty(p.numbers)
        p.numbers=1:d.nMarkers; %plot all markers if numbers is empty
    else
        if length(p.numbers)<d.nMarkers
            %sort p1.numbercolors/ncol1 according to p1.numbers
            %increase p1.numbers to have same length as d1.nMarkers and fill it up with NaNs
            tmp=repmat(colors(5,:),d.nMarkers,1);
            tmp1=nan(d.nMarkers,1)';
            for k=1:length(p.numbers)
                tmp(p.numbers(k),:)=ncol(k,:);
                tmp1(p.numbers(k))=p.numbers(k);
            end
            ncol=tmp;
            p.numbers=tmp1;
        end
    end
else
    ncol=[];
    p.numbers=[]; %fill up p1.numbers with nan
end


par.colors=colors;
par.markercolors=mcol;
par.conncolors=ccol;
par.tracecolors=tcol;
par.numbercolors=ncol;

par.numbers=p.numbers;


%fill up trace widths (twidth) to have same length as traced markers (trm) / nMarkers
if p.trl~=0
    if length(p.twidth)<d.nMarkers
        twidth=nan(d.nMarkers,1)';
        i=1;
        for k=1:length(p.trm)
            if isnan(p.trm(k))
            else
                twidth(k)=p.twidth(i);
                if i<length(p.twidth)
                    i=i+1;
                end
            end
        end
        p.twidth=twidth;
    end
end

%individual widths for connectors and traces
%fill up cwidth
if length(p.cwidth)<size(p.conn,1)
    cl=length(p.cwidth);
    cwidth=nan(size(p.conn,1),1);
    cwidth(1:length(p.cwidth))=p.cwidth;
    for k=cl+1:length(cwidth)
        if isnan(cwidth(k))
            cwidth(k)=cwidth(cl);%fill up with last given value
        end
    end
elseif length(p.cwidth)>size(p.conn,1)%if cwidth is longer than conn
    cwidth=p.cwidth(1:size(p.conn,1));
else
    cwidth=p.cwidth;
end
p.cwidth=cwidth;

% if isfield(p,'cwidth') && length(p.cwidth)>1
%     p.cwidth=p.cwidth;
% else
%     p.cwidth=repmat(p.cwidth(1),1,length(p.conn));
% end
if isfield(p,'twidth') && length(p.twidth)>1
    p.twidth=p.twidth;
else
    if ~isempty(p.trm)
        p.twidth=repmat(p.twidth(1),1,length(p.trm));
    end
end



% az and el doesn't work that well in the 3d animation. using
% 'CameraPosition' attribute of axes object instead
%az=p.az;
%el=p.el;


%d1 = mcrotate(d, az, [0 0 1]);
%d = mcrotate(d1, el, [1 0 0]); %%%%%%%

if p.perspective==0 % orthographic projection
    x=d.data(n,1:3:end);
    y=d.data(n,2:3:end);
    z=d.data(n,3:3:end);
else % perspective projection
    disp('perspective option disabled in 3D version, using orthographic')
    x=d.data(n,1:3:end);
    y=d.data(n,2:3:end);
    z=d.data(n,3:3:end);
end


    tmp=d.data(:,1:3:end);tmp=tmp(:); maxx=nanmax(tmp); minx=nanmin(tmp);
    tmp=d.data(:,2:3:end);tmp=tmp(:); maxy=nanmax(tmp); miny=nanmin(tmp);%miny=miny-abs(miny*1.2);
    tmp=d.data(:,3:3:end);tmp=tmp(:); maxz=nanmax(tmp); minz=nanmin(tmp);
    midx = (maxx+minx)/2;
    midy = (maxy+miny)/2;
    midz = (maxz+minz)/2;

%     maxx = maxx+abs(maxx*0.05);
%     maxy = maxy+abs(maxy*0.05);
%     maxz = maxz+abs(maxz*0.05);
%     minx = minx-abs(minx*0.05);
%     miny = miny-abs(miny*0.05);
%     minz = minz-abs(minz*0.05);

    maxxyz = max([maxx,maxy,maxz]);

    %axes limits
    if isfield(p,'par3D') && isfield(p.par3D,'limits') && ~isempty(p.par3D.limits)
        axesLimits = p.par3D.limits;
    else
        axesLimits = [minx maxxyz;miny maxxyz;minz maxxyz];
    end

    om = abs(round(max(axesLimits(:,2)-axesLimits(:,1)))); %order of magnitude.. used for bone widths, marker sizes and shadow widths

    if isfield(p,'par3D') && isfield(p.par3D,'drawfloor') && p.par3D.drawfloor == 1
        drawFloor = 1;
    else
        drawFloor = 0;
    end

    if isfield(p,'par3D') && isfield(p.par3D,'drawwallx') && p.par3D.drawwallx == 1
        drawXWall = 1;
    else
        drawXWall = 0;
    end

    if isfield(p,'par3D') && isfield(p.par3D,'drawwally') && p.par3D.drawwally == 1
        drawYWall = 1;
    else
        drawYWall = 0;
    end

    if isfield(p,'par3D') && isfield(p.par3D,'showaxis') && p.par3D.showaxis == 1
        showaxis = 1;
    else
        showaxis = 0;
    end

    if isfield(p,'par3D') && isfield(p.par3D,'shadowalpha') && ~isempty(p.par3D.shadowalpha)
        shadowAlpha = p.par3D.shadowalpha;
    else
        shadowAlpha = 0.25;
    end

    if shadowAlpha > 0 && (drawXWall || drawYWall || showaxis)
        wallshadow = 1;
    else
        wallshadow = 0;
    end


    if isfield(p,'par3D') && isfield(p.par3D,'shadowwidth') && ~isempty(p.par3D.shadowwidth)
        shadowWidth = ones(size(p.cwidth))*p.par3D.shadowwidth;
    else
        shadowWidth = p.cwidth;
    end



    %camera position
    if isfield(p,'par3D') && isfield(p.par3D,'cameraposition') && ~isempty(p.par3D.cameraposition)
        camPosition = p.par3D.cameraposition;
    elseif isfield(p,'az') && isfield(p,'el') && ~isempty(p.az) && ~isempty(p.el)
        [camPosition(1), camPosition(2), camPosition(3)]  = sph2cart(deg2rad(p.az),deg2rad(p.el),maxxyz*5);
    else
        camPosition = [maxx,maxy,maxz];
    end

    %light position
    if isfield(p,'par3D') && isfield(p.par3D,'lightposition') && ~isempty(p.par3D.lightposition)
        lightPos = p.par3D.lightposition;
    else
        lightPos = [maxx,maxy,maxz].*[2 2 4];
    end

    %camera target
    if isfield(p,'par3D') && isfield(p.par3D,'cameratarget') && ~isempty(p.par3D.cameratarget)
        camTarget = p.par3D.cameratarget;
    else
        camTarget = [midx midy midz];
    end


    %camera target
    if isfield(p,'par3D') && isfield(p.par3D,'zoom') && ~isempty(p.par3D.zoom)
        camDistance = p.par3D.zoom;
    else
        camDistance = 15;
    end



% %BBADd0150303: exit function here without doing the animation or plotting,
% but setting the parameters, esp. the limits, to make videos with a reduced
% set of markers that look exactly like the videos with all markers
if p.getparams==1
    par=p;
    par = orderfields(par, {'type','scrsize','limits','az','el','msize','colors','markercolors',...
    'conncolors','tracecolors','numbercolors','cwidth','twidth','conn','conn2','trm','trl',...
    'showmnum','numbers','showfnum','background','animate','fps','output','videoformat','createframes','getparams','perspective','pers'});
    return
end

fignr=1;

if p.animate %20150720 / HJ: in animate case, set figure and axes outside main loop
    f = figure(fignr);
    if p.visible==0;
        f.Visible='off';
            disp('Creating animation, please wait...');
    end
    clf;
    set(gcf, 'WindowStyle','normal');
    set(gcf,'Position',[50 50 p.scrsize(1) p.scrsize(2)]) ; % DVD: w=720 h=420
    %set(gcf, 'color', [.8 .8 .8]);
    set(gcf, 'color', bgcol);
    %view(0,90);
    %colormap([ones(64,1) zeros(64,1) zeros(64,1)]);
end

if drawFloor && isfield(p,'par3D') && isfield(p.par3D,'floorimage') && ~isempty(p.par3D.floorimage)
        floorimg = imread(p.par3D.floorimage);
        floorimgsize = size(floorimg); floorimgsize(end)=[];
        floorscale = max(axesLimits(:,2)-axesLimits(:,1))/min(floorimgsize);
end

if drawXWall && isfield(p,'par3D') && isfield(p.par3D,'wallimagex') && ~isempty(p.par3D.wallimagex)
        wallimgx = imread(p.par3D.wallimagex);
        wallimgxsize = size(wallimgx); wallimgxsize(end)=[];
        wallxscale = max(axesLimits(:,2)-axesLimits(:,1))/min(wallimgxsize);
        wallimgx = flip(wallimgx ,1);
end

if drawYWall && isfield(p,'par3D') && isfield(p.par3D,'wallimagey') && ~isempty(p.par3D.wallimagey)
        wallimgy = imread(p.par3D.wallimagey);
        wallimgysize = size(wallimgy); wallimgysize(end)=[];
        wallyscale = max(axesLimits(:,2)-axesLimits(:,1))/min(wallimgysize);
        wallimgy = flip(wallimgy ,1);
end
for k=1:size(x,1) % main loop
    if  p.animate
        clf;
        %axes('position', [0 0 1 1], 'XLim', axesLimits(1,1:2), 'YLim', axesLimits(2,1:2),'ZLim', axesLimits(3,1:2), 'CameraPosition',camPosition,'CameraTarget',camTarget,'Projection','perspective','CameraUpVector',[0 0 1],'Color',p.colors(1));
        axes('position', [0 0 1 1], 'CameraPosition',camPosition,'CameraTarget',camTarget,'Projection','perspective','CameraUpVector',[0 0 1],'Color',p.colors(1));
        %view([0 90])
        daspect([1 1 1])
        hold on;
    else
        figure(fignr);
        if p.visible==0;
            f.Visible='off';
        end
        clf;
        set(gcf, 'WindowStyle','normal');
        set(gcf,'Position',[50 50 p.scrsize(1) p.scrsize(2)]) ; % DVD: w=720 h=420
        %axes('position', [0 0 1 1], 'XLim', axesLimits(1,1:2), 'YLim', axesLimits(2,1:2),'ZLim', axesLimits(3,1:2), 'CameraPosition',camPosition,'CameraTarget',camTarget,'Projection','perspective','CameraUpVector',[0 0 1],'Color',p.colors(1));
        axes('position', [0 0 1 1], 'CameraPosition',camPosition,'CameraTarget',camTarget,'Projection','perspective','CameraUpVector',[0 0 1],'Color',p.colors(1));
        daspect([1 1 1])
        hold on
        set(gcf, 'color', bgcol);
        %view(10,150);
        %colormap([ones(64,1) zeros(64,1) zeros(64,1)]);
        fignr=fignr+1;
    end

    %plot some text to appear in background
    %text(maxx, miny, midz, {'YOUR TEXT'}, 'FontSize', 24, 'color', [.85 .15 .15]);

    if drawFloor
        floortransform = hgtransform('Matrix',makehgtform('xrotate',0,'scale',floorscale,'translate',axesLimits(:,1)/floorscale));
        image(floortransform,floorimg)
    end

    if drawXWall
        xbackwalltransform = hgtransform('Matrix',makehgtform('scale',wallxscale,'translate',axesLimits(:,1)/wallxscale,'xrotate',pi/2));
        image(xbackwalltransform,wallimgx)
    end


    if drawYWall
        ybackwalltransform = hgtransform('Matrix',makehgtform('scale',wallyscale,'translate',axesLimits(:,1)/wallyscale,'xrotate',pi/2,'yrotate',pi/2));
        image(ybackwalltransform,flip(wallimgy ,2))
    end


    % plot marker-to-marker connections
    if ~isempty(p.conn)
            for m=1:size(p.conn,1)

                r1 = [x(k,p.conn(m,1)) y(k,p.conn(m,1)) z(k,p.conn(m,1))];
                r2 = [x(k,p.conn(m,2)) y(k,p.conn(m,2)) z(k,p.conn(m,2))];
                if isfinite([r1,r2])
                    [ccx,ccy,ccz] = line2cylinder(r1,r2,p.cwidth(m)*0.003*om,50);
                    tmpbone = surf(ccx,ccy,ccz);
                    tmpbone.EdgeColor = 'none';
                    tmpbone.FaceColor = ccol(m,:); % p.colors(3);

                    %shadow coordinates for each connection on each axis
                    if wallshadow
                        %X axis shadow
                        SPax = shadowPoint([0 1 0],[0 axesLimits(2,1) 0],lightPos,[x(k,p.conn(m,1)) y(k,p.conn(m,1)) z(k,p.conn(m,1))]);
                        SPbx = shadowPoint([0 1 0],[0 axesLimits(2,1) 0],lightPos,[x(k,p.conn(m,2)) y(k,p.conn(m,2)) z(k,p.conn(m,2))]);
                        if lightPos(2) > y(k,p.conn(m,1)) && lightPos(2) > y(k,p.conn(m,2)) && ((SPax(1) > axesLimits(1,1) && SPax(3) > axesLimits(3,1)) || (SPbx(1) > axesLimits(1,1) && SPbx(3) > axesLimits(3,1)))
                            qqq = line2rect(SPax([1,3]),SPbx([1,3]),shadowWidth(m)*0.005*om);
                            patchdepth = ones(4,1)*SPax(2)*(p.cwidth(m)*0.001*log(om));
                            sx = patch([qqq(:,1);qqq(:,1)],SPax(2)-[patchdepth; -patchdepth],[qqq(:,2);qqq(:,2)]   ,'k','EdgeColor','none','FaceLighting','none');alpha(sx,shadowAlpha);
                        end

                        %Y axis shadow
                        SPay = shadowPoint([1 0 0],[axesLimits(1,1) 0 0],lightPos,[x(k,p.conn(m,1)) y(k,p.conn(m,1)) z(k,p.conn(m,1))]);
                        SPby = shadowPoint([1 0 0],[axesLimits(1,1) 0 0],lightPos,[x(k,p.conn(m,2)) y(k,p.conn(m,2)) z(k,p.conn(m,2))]);
                        if lightPos(1) > x(k,p.conn(m,1)) && lightPos(1) > x(k,p.conn(m,2)) && ((SPay(2) > axesLimits(2,1) && SPay(3) > axesLimits(3,1)) || (SPby(2) > axesLimits(2,1) && SPby(3) > axesLimits(3,1)))
                            qqq = line2rect(SPay([2,3]),SPby([2,3]),shadowWidth(m)*0.005*om);
                            patchdepth = ones(4,1)*SPay(1)*(p.cwidth(m)*0.001*log(om));
                            sy = patch(SPay(1)-[patchdepth; -patchdepth],[qqq(:,1);qqq(:,1)],[qqq(:,2);qqq(:,2)]   ,'k','EdgeColor','none','FaceLighting','none');alpha(sy,shadowAlpha);
                        end
                    end

                    %Z axis shadow
                    if shadowAlpha > 0
                        SPaz = shadowPoint([0 0 1],[0 0 axesLimits(3,1)],lightPos,[x(k,p.conn(m,1)) y(k,p.conn(m,1)) z(k,p.conn(m,1))]);
                        SPbz = shadowPoint([0 0 1],[0 0 axesLimits(3,1)],lightPos,[x(k,p.conn(m,2)) y(k,p.conn(m,2)) z(k,p.conn(m,2))]);
                        if ~drawXWall || ~drawYWall || (SPaz(1) > axesLimits(1,1) && SPaz(2) > axesLimits(2,1)) || (SPbz(1) > axesLimits(1,1) && SPbz(2) > axesLimits(2,1))
                            qqq = line2rect(SPaz([1,2]),SPbz([1,2]),shadowWidth(m)*0.005*om);
                            patchdepth = ones(4,1)*SPaz(3)*(p.cwidth(m)*0.001*log(om));
                            sz = patch([qqq(:,1);qqq(:,1)],[qqq(:,2);qqq(:,2)],SPaz(3)-[patchdepth; -patchdepth]   ,'k','EdgeColor','none','FaceLighting','none');alpha(sz,shadowAlpha);
                        end
                    end
                end

            end
    end
    grid on
    % plot midpoint-to-midpoint connections
    if ~isempty(p.conn2)

         for m=1:size(p.conn2,1)
             if isfinite(x(k,p.conn2(m,1))*x(k,p.conn2(m,2))*x(k,p.conn2(m,3))*x(k,p.conn2(m,4)))
                tmpx1 = (x(k,p.conn2(m,1))+x(k,p.conn2(m,2)))/2;
                tmpx2 = (x(k,p.conn2(m,3))+x(k,p.conn2(m,4)))/2;
                tmpy1 = (y(k,p.conn2(m,1))+y(k,p.conn2(m,2)))/2;
                tmpy2 = (y(k,p.conn2(m,3))+y(k,p.conn2(m,4)))/2;
                tmpz1 = (z(k,p.conn2(m,1))+z(k,p.conn2(m,2)))/2;
                tmpz2 = (z(k,p.conn2(m,3))+z(k,p.conn2(m,4)))/2;

                r1 = [tmpx1 tmpy1 tmpz1];
                r2 = [tmpx2 tmpy2 tmpz2];

                if isfinite([r1,r2])
                    [ccx,ccy,ccz] = line2cylinder(r1,r2,p.cwidth(m)*0.003*om,50);
                    tmpbone = surf(ccx,ccy,ccz);
                    tmpbone.EdgeColor = 'none';
                    tmpbone.FaceColor = ccol(m,:); %p.colors(3);

                    %shadow coordinates for each connection on each axis
                    if wallshadow
                        %X axis shadow
        				SPax = shadowPoint([0 1 0],[0 miny 0],lightPos,[tmpx1 tmpy1 tmpz1]);
                        SPbx = shadowPoint([0 1 0],[0 miny 0],lightPos,[tmpx2 tmpy2 tmpz2]);
                        if lightPos(2) > tmpy1 && lightPos(1) > tmpy2 && ((SPax(1) > axesLimits(1,1) && SPax(3) > axesLimits(3,1)) || (SPbx(1) > axesLimits(1,1) && SPbx(3) > axesLimits(3,1)))
                            qqq = line2rect(SPax([1,3]),SPbx([1,3]),shadowWidth(m)*0.005*om);
                            patchdepth = ones(4,1)*SPax(2)*(p.cwidth(m)*0.001*log(om));
                            sx = patch([qqq(:,1);qqq(:,1)],SPax(2)-[patchdepth; -patchdepth],[qqq(:,2);qqq(:,2)]   ,'k','EdgeColor','none','FaceLighting','none');alpha(sx,shadowAlpha);
                        end

                        %Y axis shadow
                        SPay = shadowPoint([1 0 0],[minx 0 0],lightPos,[tmpx1 tmpy1 tmpz1]);
                        SPby = shadowPoint([1 0 0],[minx 0 0],lightPos,[tmpx2 tmpy2 tmpz2]);
                        if lightPos(1) > tmpx1 && lightPos(1) > tmpx2 && ((SPay(2) > axesLimits(2,1) && SPay(3) > axesLimits(3,1)) || (SPby(2) > axesLimits(2,1) && SPby(3) > axesLimits(3,1)))
                            qqq = line2rect(SPay([2,3]),SPby([2,3]),shadowWidth(m)*0.005*om);
                            patchdepth = ones(4,1)*SPay(1)*(p.cwidth(m)*0.001*log(om));
                            sy = patch(SPay(1)-[patchdepth; -patchdepth],[qqq(:,1);qqq(:,1)],[qqq(:,2);qqq(:,2)]   ,'k','EdgeColor','none','FaceLighting','none');alpha(sy,shadowAlpha);
                        end
                    end

                    if shadowAlpha > 0
                            %Z axis shadow
                            SPaz = shadowPoint([0 0 1],[0 0 minz],lightPos,[tmpx1 tmpy1 tmpz1]);
                            SPbz = shadowPoint([0 0 1],[0 0 minz],lightPos,[tmpx2 tmpy2 tmpz2]);
                        if ~drawXWall || ~drawYWall || (SPaz(1) > axesLimits(1,1) && SPaz(2) > axesLimits(2,1)) || (SPbz(1) > axesLimits(1,1) && SPbz(2) > axesLimits(2,1))
                            qqq = line2rect(SPaz([1,2]),SPbz([1,2]),shadowWidth(m)*0.005*om);
                            patchdepth = ones(4,1)*SPaz(3)*(p.cwidth(m)*0.001*log(om));
                            sz = patch([qqq(:,1);qqq(:,1)],[qqq(:,2);qqq(:,2)],SPaz(3)-[patchdepth; -patchdepth]   ,'k','EdgeColor','none','FaceLighting','none');alpha(sz,shadowAlpha);
                        end
                    end
                end

             end
         end

    end

    % plot traces if animation
    if p.animate && p.trl~=0
%         trml=sort(p.trm);%BB: sorting marker traces
        trlen = round(p.fps * p.trl);
        start=max(1,k-trlen);
        ind = start-1+find(~isnan(x(start:k)));
        for m=1:length(p.trm)
            if isnan(p.trm(m)) %BBFIX 20120404 mcmerge adaption - NaN traces not plotted
            else
                plot3(x(ind,m),y(ind,m),z(ind,m),'-','Color',tcol(m,:),'Linewidth',p.twidth(m));
            end
        end
    end


    % plot markers
    [px,py,pz] = sphere(50); % generate coordinates for a 50 x 50 sphere

    px=px*p.msize*0.0015*om;
    py=py*p.msize*0.0015*om;
    pz=pz*p.msize*0.0015*om;

    for m=1:size(x,2)
        if isfield(p,'par3D') && isfield(p.par3D,'jointrotations') && p.par3D.jointrotations==1
            Q = d.other.quat(k,(1:4)+4*(m-1));% expressed as XYZW
            Q = Q([4 1 2 3]); % reorder to WXYZ
        end
        markerBall = surface(px+x(k,m), py+y(k,m),flip(pz)+z(k,m));
        markerBall.FaceColor = mcol(m,:);% p.colors(2);
        markerBall.EdgeColor = 'none';              % remove surface edge color

        if isfield(p,'par3D') && isfield(p.par3D,'jointrotations') && p.par3D.jointrotations==1
            extra = p.msize*0.0025*om;
            lwidth = 2;
            or = [x(k,m),y(k,m),z(k,m)];
            alx = (extra*quat2rotmat(Q))+or';
            old = get( 0, 'defaultAxesColorOrder' );
            set( 0, 'defaultAxesColorOrder', [0,0,1; 0,0.5,0; 1,0,0] );
            plot3([repmat(or(1),1,3); alx(1,:,:,1) ], [repmat(or(2),1,3) ; alx(2,:,:,1)], [repmat(or(3),1,3); alx(3,:,:,1)], '-', 'LineWidth', lwidth );
        end
    end

    if showaxis
        axis on
    else
        axis off
    end

    if p.showfnum
        h=text(minx+0.95*(maxx-minx), miny+0.05*(maxy-miny), minz+0.05*(maxz-minz), num2str(k),...
            'HorizontalAlignment','Right','FontSize',12,'FontWeight','bold');
        set(h,'Color',colors(5,:))
    end

%     %plot some copywrite text or anything else - BB20121102
%     text(maxxx-650, minzz+350, {'Jyv?skyl? Music & Motion Capture'}, 'FontSize', 24, 'color', [.9 .9 .9]);
%     text(maxxx-300, 0, {'Birgitta Burger', 'Jyv?skyl? Univ.', 'Finland'});
%     text(minxx+40, minzz+0.97*(maxzz-minzz), 'High Sub-Band 2 Flux', 'FontSize', 16, 'FontWeight', 'bold');
%     text(minxx+70, minzz+0.97*(maxzz-minzz)-75, {'high speed of head'}, 'FontSize', 12, 'FontWeight', 'bold');

    light('Position',lightPos)
    set(gca,'CameraViewAngle',camDistance)


    drawnow
    hold off
    drawnow
    hold off
    if p.animate
        if p.createframes==1
            fn=['frame', sprintf('%0.4d',k),'.png']; %old version: create frames
            imwrite(frame2im(getframe(gcf)),fn,'png');
%             fn=['frame', sprintf('%0.4d',k),'.eps'];
%             saveas(gcf, fn, 'eps');
        elseif p.createframes==2 %MH20200312 (animated gif)
            im=frame2im(getframe(gcf));
            [imind,cm]=rgb2ind(im,256);
            if k == 1
                imwrite(imind,cm,fn,'gif','Loopcount',inf,'DelayTime',1/p.fps)
            else
                imwrite(imind,cm,fn,'gif','WriteMode','append','DelayTime',1/p.fps)
            end
        else
            writeVideo(movObj,getframe(gcf)); %BB_NEW_20140212 for VideoWriter
        end

        if k == 1
            fprintf('Writing video frame number                     ')
        end
        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b')
        fprintf('%8d of %8d',k,size(x,1))

    end
end
fprintf('\n')

if p.animate
    if p.createframes==0
        %close
        close(movObj);
    else %close(gcf);
    end
    cd(currdir);
end


return;

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

    return;

end


function SP = shadowPoint(planeNormalVec,pointOnPlane,p1,p2)

    SP = p1+(-dot(planeNormalVec,p1 - pointOnPlane) / dot(planeNormalVec,p2-p1)).*(p2-p1);

end


function rectangleCoordinates = line2rect(p1,p2,w)

    th = atan2(p2(1)-p1(1),p2(2)-p1(2));

    x2 = .5*w*cos(0.5*pi-th);
    y2 = .5*w*sin(0.5*pi+th);

    r1(1) = p1(1)-y2;
    r2(1) = p1(2)+x2;
    r1(2) = p1(1)+y2;
    r2(2) = p1(2)-x2;
    r1(4) = p2(1)-y2;
    r2(4) = p2(2)+x2;
    r1(3) = p2(1)+y2;
    r2(3) = p2(2)-x2;

    rectangleCoordinates = [r1' r2'];

end


function [ccx, ccy, ccz] = line2cylinder(p1,p2,r,n)

    circleSubdivisions=linspace(0,2*pi,n);

    circlePlane=null(p1-p2);

    points1=p1'+r*(circlePlane(:,1)*cos(circleSubdivisions)+circlePlane(:,2)*sin(circleSubdivisions));
    points2=p2'+r*(circlePlane(:,1)*cos(circleSubdivisions)+circlePlane(:,2)*sin(circleSubdivisions));

    ccx = [points1(1,:); points2(1,:)];
    ccy = [points1(2,:); points2(2,:)];
    ccz = [points1(3,:); points2(3,:)];

end
