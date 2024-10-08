function p = mcinitanimpar(x)
% Initializes an animation parameter (animpar) structure.
%
% syntax
% ap = mcinitanimpar;
% ap = mcinitanimpar('3D'); %initiates animation parameters for 3D
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
%   background: background image or video parameters:
%        input: background image (e.g. 'peppers.png') or video ('xylophone.mp4') to be displayed as a background to the mocap data ([]). Note that, when using videos with [`mcplotframe`](4.-function-reference#mcplotframe), always the first video frame will be displayed. When videos are used with [`mcanimate`](4.-function-reference#mcanimate), the videos will be played at the frame rate specified in the fps animation parameter structure field.
%        fillfigure: resizes the image or video to fill the entire figure (`scrsize` can be modified accordingly to keep the aspect ratio of the video), 1=yes, 0=no (0)
%        starttime: timestamp (in seconds) of the first video frame to read, specified as a numeric scalar. The value can be between zero and the duration of the video (0)
%   animate: create animation, 1=yes, 0=no (0)
%   visible: state of visibility of the figure, 1=yes, 0=no (1)
%   hold: retain the current or the upcoming plot (similar functionality to 'hold on' in Matlab), 1=yes, 0=no (0)
%   fps: frames per second for animation (30)
%   output: either file name for video file, of folder for pgn frames ('tmp')
%   videoformat: specifies video file format, either 'avi' or 'mpeg4' ('avi')
%   createFrames: create png frames or animated gif instead of video file, 2 = animated gif, 1=frames, 0=video file (0)
%   getparams: return animation parameters, without plotting or animating frames, 1=yes, 0=no (0)
%   perspective: perform perspective projection, 0 = orthographic (default), 1 = perspective (0)
%   pers: perspective projection parameters:
%       pers.c: 3D position of the camera [0 -4000 0]
%       pers.th: orientation of the camera [0 0 0]
%       pers.e: viewer's position relative to the display surface [0 -2000 0]
%
%   par3D: parameters for plotting in 3D using mcplot3Dframe or mcanimate:
%       par3D.jointrotations: visualize joint rotation, 1=yes, 0=no (0) (requires joint rotation data, see note below)
%       par3D.shadowalpha: opacity of shadows (0.25)
%       par3D.showaxis: show axis, 1=yes, 0=no (0)
%       par3D.limits: 3D plot limits [xmin xmax;ymin ymax;zmin zmax] ([])
%       par3D.lightposition: position of the light source ([])
%       par3D.cameraposition: position of the camera ([])
%       par3D.shadowwidth: width of the shadows ([])
%       par3D.drawfloor: show floor image, 1=yes, 0=no (0)
%       par3D.floorimage: url of floor image ([])
%       par3D.drawwallx = show x wall image, 1=yes, 0=no (0)
%       par3D.wallimagex: url of x wall image ([])
%       par3D.drawwally = show y wall image, 1=yes, 0=no (0)
%       par3D.wallimagey: url of y wall image ([])
%
% Note that in 3D mode the following changes are made to the 2D defaults:
%       colors are changed to 'wwwww'
%       az is changed to 60
%       el is changed to 10
%
% Note that the use of par3D.jointrotations requires that the mocap/joint structure contains an 'other.quat' field containing a time by component matrix where each joint rotation (with respect to the global coordinate system defined in calibration) is represented in quaternions using the 'scalar last' convention (X Y Z W). This field is automatically generated by mcread.m for Qualysis .tsv exports based on Theia3D markerless pose estimation.
%
% Colors can be given as strings if only the MATLAB string color options are used.
% However, any color can be specified by using RGB triplets - for example,
% plotting the first two markers in gray: par.markercolors=[.5 .5 .5; .5 .5 .5];
%
% see also
% mccreateconnmatrix, mcplotframe, mcanimate, mcanimatedata, mcplot3Dframe, mcplayer
%
% Download the MoCap Toolbox from
% https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mocaptoolbox
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

p.type = 'animpar';

p.scrsize = [800 600];
p.limits = [];

p.az = 0;
p.el = 0;

p.mshape = 'o';
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
p.background.input = [];
p.background.fillfigure = 0;
p.background.starttime = 0;
p.animate = 0;
p.visible = 1;
p.hold = 0;
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


if nargin > 0
    if strcmpi(x,'3D')
        p.par3D.jointrotations = 0;
        p.par3D.shadowalpha = 0.25;
        p.par3D.showaxis = 0;
        p.par3D.limits = [];
        p.par3D.lightposition = [];
        p.par3D.cameraposition = [];
        p.par3D.shadowwidth = [];
        p.par3D.drawfloor = 0;
        p.par3D.floorimage = [];
        p.par3D.drawwallx = 0;
        p.par3D.wallimagex = [];
        p.par3D.drawwally = 0;
        p.par3D.wallimagey = [];
        p.colors = 'wwwww';
        p.az = 60;
        p.el = 10;
    end
end
