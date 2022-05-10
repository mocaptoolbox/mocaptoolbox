function p = mcinitanimpar
% Initializes an animation parameter (animpar) structure.
%
% syntax
% ap = mcinitanimpar;
%
% input parameters
% (none)
%
% output
% ap: animaton parameter (animpar) structure
%
% comments
% The animpar structure contains the following fields
% (initialized values given in parentheses):
%   scrsize: screen size in pixels ([800 600])
%   limits: plot limits [xmin xmax zmin zmax] ([])
%   az: azimuth vector in degrees (0)
%   el: elevation vector in degrees (0)
%   msize: marker size (12)
%   colors: [background marker connection trace number] ('kwwww')
%   markercolors: String holding marker colors ([]) or RGB triplet
%   conncolors: String holding connector (line) colors ([]) or RGB triplet
%   tracecolors: String holding trace colors (only animations) ([]) or RGB triplet
%   numbercolors: String holding number colors (indicated in the numbers array) ([]) or RGB triplet
%   cwidth: width of connectors (either single value or vector with entries for different widths) (1)
%   twidth: width of traces (either single value or vector with entries for different widths) (1)
%   conn: marker-to-marker connectivity matrix (M x 2) ([])
%   conn2: midpoint-to-midpoint connectivity matrix (M x 4) ([])
%   trm: vector indicating markers for which traces are added ([])
%   trl: length of traces in seconds (0)
%   showmnum: show marker numbers, 1=yes, 0=no (0)
%   numbers: array indicating the markers for which number is to be shown ([])
%   showfnum: show frame numbers, 1=yes, 0=no (0)
%   animation: create animation, 1=yes, 0=no (0)
%   fps: frames per second for animation (30)
%   output: either file name for video file, of folder for pgn frames ('tmp')
%   videoformat: specifies video file format, either 'avi' or 'mpeg4' ('avi')
%   createFrames: create png frames instead of video file, 1=frames, 0=video file (0)
%   getparams: return animation parameters, without plotting or animating frames, 1=yes, 0=no (0)
%   perspective: perform perspective projection, 0 = orthographic (default), 1 = perspective (0)
%   pers: perspective projection parameters:
%       pers.c: 3D position of the camera [0 -4000 0]
%       pers.th: orientation of the camera [0 0 0]
%       pers.e: viewer's position relative to the display surface [0 -2000 0]
% 
% Colors can be given as strings if only the MATLAB string color options are used. 
% However, any color can be specified by using RGB triplets - for example, 
% plotting the first two markers in gray: par.markercolors=[.5 .5 .5; .5 .5 .5];  
%
% see also
% mccreateconnmatrix, mcplotframe, mcanimate
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

p.type = 'animpar';

p.scrsize = [800 600];
p.limits = [];

p.az = 0;
p.el = 0;

p.msize = 12;
p.colors = 'kwwww'; 
p.markercolors = [];
p.conncolors = [];
p.tracecolors = [];
p.numbercolors = [];
p.cwidth = 1;
p.twidth = 1;

p.conn = [];
p.conn2 = [];
p.trm = [];
p.trl = 0;

p.showmnum = 0;
p.numbers = [];
p.showfnum = 0;

p.animate = 0;
p.fps = 30;
p.output = 'tmp';
p.videoformat = 'avi';
p.createframes = 0;
p.getparams = 0;
p.perspective = 0;
% parameters for perspective projection
p.pers.c=[0 -4000 0];
p.pers.th=[0 0 0];
p.pers.e=[0 -2000 0];


