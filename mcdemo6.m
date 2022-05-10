function mcdemo6
% This example shows how you can create animations
% with the MoCap toolbox. 
%
% You can either produce an animation video (.avi or .mp4 format) or 
% animation frames (single .png files) with the MoCap toolbox. In this 
% tutorial we will produce an .avi file.

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us create an animation from the variable walk2.
% The animpar structure mapar contains the connector
% information for this variable:

load mcdemodata
mapar

% Let us change the frames-per-second value to 15 
mapar.fps = 15;

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% In the next dialog window, choose the directory 
% where you want the video to be stored:

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
path = uigetdir([], 'Pick a Directory')

olddir = cd; cd(path)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we make the animation:

newpar = mcanimate(walk2, mapar);

% The animation is created and saved here:

disp([path '/' mapar.output '.avi'])

% Enjoy watching the video!

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

cd(olddir)
