function mcdemo9
% This demo explains the possibility of creating an animation with a 
% perspective (three-dimensional) effect.  
% 
% We will create a couple of animations of the walk2 data, with and without 
% the perspective projection to see the differences. 
 
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Let us load the mcdemodata and change a couple of parameters of the animpar structure mapar

load mcdemodata
mapar.scrsize=[600 400];
mapar.msize=8;
mapar.fps=15;
mapar.colors='wkkkk';

% And we also set the azimuth parameter in the animpar structure mapar,
% so that the walker will walk towards us

mapar.az=270;

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Now we are ready to create an animation. 
% In the next dialog window, choose the directory 
% where you want the frames to be stored:

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
path = uigetdir([], 'Pick a Directory')

olddir = cd; cd(path)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% To create seperate frames instead of a video and give a folder name,
% into which the frames are stored
mapar.createframes = 1;
mapar.output = 'pers0';

% Now we create an animation out of that
mcanimate(walk2, mapar);

% The animation is created and saved here:

disp([path '/' mapar.output])

cd(olddir)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The figure appears to walk on the spot, although she is actually walking forwards. 
% The idea of the perspective projection is to visualize that the figure is actually
% walking forward. To activate the perspective projection, we call the mcanimate function
% again, but with one additional parameter:

% First choose again a directory where you want the frames to be stored:

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
path = uigetdir([], 'Pick a Directory')

olddir = cd; cd(path)

mapar.output = 'pers1';

mapar.perspective = 1;

mcanimate(walk2, mapar);

% The animation is created and saved here:

disp([path '/' mapar.output])

cd(olddir)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc

% This animation looks far more natural regarding the movement
% direction of the walker.
% The parameters for the perspective projection are set in the pers part of
% the animpar structure mapar

mapar.pers

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% The field c sets the 3D position of the camera, th is the
% orientation of the camera, and e stores the viewer's position relative to
% the display surface. We can now change, for example, the camera position 
% and create another animation to see what happens.

mapar.output = 'pers2';

mapar.pers.c=[1000 -4000 1000];

% First choose the directory where you want the frames to be stored:

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
path = uigetdir([], 'Pick a Directory')

olddir = cd; cd(path)

mcanimate(walk2, mapar);

% The animation is created and saved here:

disp([path '/' mapar.output])

% Enjoy watching and comparing the frames!

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

cd(olddir)


