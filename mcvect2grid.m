function [g, gp] = mcvect2grid(c, p, dx, dy)
% Converts a MoCap structure vector to a MoCap structure with three orthogonal views
% for each component.
%
% syntax
% [g, gp] = mcvect2grid(c, p, dx, dy);
%
% input parameters
% c: MoCap structure vector
% p: animpar structure
% dx: horizontal offset between components (default: 2000)
% dy: vertical offset between orthogonal views (default: 2000)
%
% output
% g: MoCap structure
% gp: animpar structure
%
% examples
% [g, gpar] = mcvect2grid(c, par, 1000, 2000); 
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

g=[];
gp=[];

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if nargin>=3 && (~isnumeric(dx) || length(dx)>1)
    disp([10, 'The third input argument has to be a numeric.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if nargin==4 && (~isnumeric(dy) || length(dy)>1)
    disp([10, 'The forth input argument has to be a numeric.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end



if nargin<4, dy = 2000; end
if nargin<3, dx = 2000; end


if isfield(c(1),'type') && strcmp(c(1).type, 'MoCap data') && isfield(p,'type') && strcmp(p.type, 'animpar')
    g = c(1); gp = p;
    [g,gp]=mcmerge(g,mctranslate(mcrotate(c(1),90),[0 0 -dy]),gp,p);
    [g,gp]=mcmerge(g,mctranslate(mcrotate(c(1),90, [1 0 0]),[0 0 -2*dy]),gp,p);
    if length(c)>1
        for k=2:length(c)
            [g,gp]=mcmerge(g,mctranslate(c(k),[(k-1)*dx 0 0]),gp,p);
            [g,gp]=mcmerge(g,mctranslate(mcrotate(c(k),90),[(k-1)*dx 0 -dy]),gp,p);
            [g,gp]=mcmerge(g,mctranslate(mcrotate(c(k),90, [1 0 0]),[(k-1)*dx 0 -2*dy]),gp,p);
        end
    end
else
    disp([10, 'The first input argument should be a MoCap data structure.']);
    disp(['The second input argument should be an animpar structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end


