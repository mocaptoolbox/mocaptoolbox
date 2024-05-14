function mcplayer(d,options)
% 3D playback of motion capture data.
%
% syntax
%
% mcplayer(d)
% mcplayer(__,Name,Value);
%
% input parameters
%
% d: MoCap data structure
%
% Name-value arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%
%   p (optional): MoCap animation parameter structure (see mcinitanimpar)
%   play (optional): initialize animation (default: true)
%   speed (optional): playback speed value in a range between 1 and 200 (default: 5)
%   figurehandle (optional): handle to a figure (optional)
%
% output
%
% examples
%
% mc3dplot(d)
% mc3dplot(d, p=mapar, play=false)
% mc3dplot(d, p=mapar, play=true,speed=3)
% myfig=figure; mc3dplot(d, p=mapar, speed=7, play=true,figurehandle=myfig)
%
% comments
% It is recommended to close all figures before running mcplayer. The function uses p.markercolors to set the marker colors (p.colors is not used).
% Created by Mickaël Tits, numediart Institute, University of Mons, Belgium (21/12/2017). Original version of this function was called mc3dplot.m (https://github.com/numediart/MocapRecovery/tree/master/MoCapToolboxExtension)
%
% see also
% mcanimate, mcplotframe, mcplot3Dframe, mcinitanimpar, mcanimatedata
arguments
    d
    options.p = mcinitanimpar()
    options.figurehandle = figure
    options.speed = 100;
    options.play = true;
end

global play;
global gframeid;
global gspeed;
gspeed = options.speed;
play = options.play;
p=options.p;
gframeid = 1;

fig = options.figurehandle;

clf;

allx = d.data(1:3:end,:);
ally = d.data(2:3:end,:);
allz = d.data(3:3:end,:);

p.minx = nanmin(nanmin(allx));
p.miny = nanmin(nanmin(ally));
p.minz = nanmin(nanmin(allz));
p.maxx = nanmax(nanmax(allx));
p.maxy = nanmax(nanmax(ally));
p.maxz = nanmax(nanmax(allz));

set(fig,'Position',[50 50 p.scrsize(1) p.scrsize(2)]);

fig.CloseRequestFcn = @myclose_req;

scatter3(1,1,1);%dummy plot to initialize view orientation
plotframe(d,p,gframeid);

hold on;
uislider = uicontrol('Parent',fig,'Style','slider','Position',[0 20 p.scrsize(1) 20],...
    'value',1, 'min',1, 'max',d.nFrames);
uislider.Callback = @(es,ed) plotframe(d,p,es.Value);

uiplaystop =  uicontrol('Style', 'togglebutton', 'String', 'Play / Pause',...
    'Position', [20 40 100 20]);

uiplaystop.Value = play;
uiplaystop.Callback = @(es,ed) playloop(d,p,es.Value);

speedslider = uicontrol('Parent',fig,'Style','slider','Position',[130 40 200 20],...
    'value',gspeed, 'min',1, 'max',200);
speedslider.Callback = @(es,ed) setspeed(es.Value);


%uislider.HandleVisibility = 'off';
hold off;
playloop(d,p,play);
end

%%

function plotframe(d,p,newframeid,play,gframeid)

gframeid = newframeid;
if gframeid > d.nFrames
    gframeid = 1;
    newframeid = 1;
end
[az,el] = view();

newframeid = round(newframeid);
if newframeid < 1
    newframeid = 1;
elseif newframeid > d.nFrames
    newframeid = d.nFrames;
end

frame = d.data(newframeid,:);
x = frame(1:3:end);
y = frame(2:3:end);
z = frame(3:3:end);
hold off;
if isempty(p.markercolors)
    scatter3(x,y,z,'b');
else
    scatter3(x,y,z,36,p.markercolors);
end
hold on;
try
    if isempty(p.conncolors)
        for i = 1:length(p.conn)
            plot3(x(p.conn(i,:)),y(p.conn(i,:)),z(p.conn(i,:)),'b');
        end
    else
        for i = 1:length(p.conn)
            plot3(x(p.conn(i,:)),y(p.conn(i,:)),z(p.conn(i,:)),'Color',p.conncolors(i,:));
        end
    end
catch
    warning('Connections data does not correspond to markers data. Check your parameter p.conn, or simply remove it.');
end


axis([p.minx p.maxx p.miny p.maxy p.minz p.maxz]);

view(az,el);
try
    drawnow;
catch
    play = false;
end
end

function playloop(d,p,playing)

global play;
global gframeid;
global gspeed;
play = playing;

while play
    gframeid = gframeid+round(gspeed);
    if gframeid > d.nFrames
        gframeid = 1;
    end
    try
        fig = gcf;
    catch
        play = false;
        return;
        %Figure probably closed without stopping the player
    end
    try
        fig.Children(length(fig.Children)-1).Value = gframeid;
        plotframe(d,p,gframeid)
    catch
        %warning('UI slider could not be updated. Figure probably closed without stopping the player.');
        play = false;
    end
end

end

function setspeed(speed)

global gspeed;
gspeed = speed;
end

function myclose_req(src,callbackdata)

global play;
play = false;
closereq;

end
