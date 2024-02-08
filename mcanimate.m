function p = mcanimate(d, p, proj)
% Creates animation of mocap data and saves it to file (.avi or .mpeg-4) or as consecutive
% frames (.png). Matlab's VideoWriter function is used to create the video
% file.
% COMPATIBILITY NOTES (v. 1.5): The 'folder'-field (animpar structure, v. 1.4) has been changed to
% 'output' and is used as file name for the animation (and stored to the current directory)
% or as folder name in case frames are to be plotted.
% Please use the function without the projection input argument, but specify
% it in the animation structure instead.
%
% syntax
% p = mcanimate(d);
% p = mcanimate(d, p);
%
% input parameters
% d: MoCap data structure
% p: animpar structure (optional)
% [depricated: proj: projection used: 0 = orthographic (default), 1 = perspective
%                    this flag is supposed to be set in the animation parameter stucture instead]
%
% output
% p: animpar structure used for plotting the frames
%
% examples
%% 2D animation
% load mcdemodata
% mcanimate(dance1,mapar)
%
%% 3D animation
% ap = mcinitanimpar('3D');
% ap.conn=mapar.conn;
% % add floor image
% ap.par3D.wallimagex = 'saturn.png';
% ap.par3D.wallimagey = 'fabric.png';
% ap.par3D.floorimage= 'rice.png';
% ap.par3D.drawfloor = 1;
% ap.par3D.drawwallx = 1;
% ap.par3D.drawwally = 1;
% % add some color
% ap.colors='wbgww';
% % animate
% mcanimate(dance2,ap)
%
%% 3D animation with joint rotations (for data imported from Qualysis + Theia 3D markerless pose estimation)
% [d japar] = mcread('filename.tsv');
% japar.par3D.jointrotations=1;
% mcanimate(d,japar)
%
%
% comments
% If the animpar structure is not given as input argument, the function
% creates it by calling the function mcinitanimpar and setting the .limits field
% of the animpar structure automatically so that all the markers fit into all frames.
% If the par.pers field (perspective projection) is not given, it is created internally for backwards
% compatibility. For explanation of the par.pers field, see help mcinitanimpar
%
% If the joint animation parameter field par3D.jointrotations is set to 1, mcanimate draws axes in each joint to represent rotations with respect to the global coordinate system defined in calibration (for data imported from Qualysis + Theia 3D markerless pose estimation)
%
% see also
% mcplotframe, mcplot3Dframe, mcinitanimpar, mcanimatedata
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland


if nargin>2
    disp([10, 'Please note that, from MCT version 1.5, the perspective projection flag is set in the field "perspective" in the animation parameters. Please adapt your code accordingly.', 10])
    p.perspective=proj;
end

if nargin<2
    p = mcinitanimpar;
end

% resample color data if time series
if ~isempty(p.markercolors) & ndims(p.markercolors == 3)
    p.markercolors = resamp(p.markercolors,d.freq,p.fps,'linear');
end
if ~isempty(p.conncolors) & ndims(p.conncolors == 3)
    p.conncolors = resamp(p.conncolors,d.freq,p.fps,'linear');
end

% resample for p.fps fps movie
d2 = mcresample(d, p.fps);




p.animate = 1;

if isfield(p,'par3D')
    p = mcplot3Dframe(d2,1:d2.nFrames,p);
else
    p = mcplotframe(d2,1:d2.nFrames,p); % output parameter added 240608
end
end
