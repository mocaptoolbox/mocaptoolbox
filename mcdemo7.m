function mcdemo7
% This example shows how MoCap data from different sessions
% can be combined into the same animation.
%
% It also shows how the viewing angle can be changed dynamically.
% Let us create a 10-second animation with two dancers and 
% a dynamically moving viewing angle:

load mcdemodata
dance1 = mcfillgaps(dance1);
d1 = mctrim(dance1, 0, 10); % take first 10 seconds
d2 = mctrim(dance2, 0, 10);
mapar.az = [0 180]; % azimuth changes from 0 to 180 degrees during the animation
mapar.el = [45 -45]; % elevation changes from 45 to -45 degrees
mapar.fps = 15; % 15 frames per second
mapar.output = 'twodancers';
[d, par] = mcmerge(d1, mctranslate(d2, [2000 0 0]), mapar, mapar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% In the next dialog window, choose the directory 
% where you want the video to be stored:

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

path = uigetdir([], 'Choose a Directory')

olddir = cd; cd(path)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Now we make the animation:

newpar = mcanimate(d, par);

% The animation is created and saved here:

disp([path '/' par.output '.avi'])

% Enjoy watching the video!

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

cd(olddir)
