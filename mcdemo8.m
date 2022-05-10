function mcdemo8
% This example shows how you can color your plots and animations
% with the MoCap toolbox. 

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us create a colored animation from the variable dance2.
% The animation parameters look like this:

load mcdemodata
mapar

% Let us change the frames-per-second value to 15 
mapar.fps = 15;

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Let us set individual colors for six markers (head front left, head back right, shoulder left,
% hip left back, finger right, knee left, knee right, heel left)
mapar.markercolors='bwwgwrwwwwwywwwwwwmwcbwg';

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% and let us have a look at the new colors:
mcplotframe(dance2, 150, mapar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Looks good. Now let us set the markers that we want to trace and the trace length (in seconds)
mapar.trm=[1 6 12 19 21 24];
mapar.trl=3;

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Let us set individual colors for the traces
mapar.tracecolors='grymcb';

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% We rotate the figure to be frontal on average

dance2=mc2frontal(dance2,9,10);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% In the next dialog window, choose the directory 
% where you want the video to be stored:

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
path = uigetdir([], 'Pick a Directory')

olddir = cd; cd(path)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Now we make the animation:

newpar = mcanimate(dance2, mapar);

% The animation is created and saved here:

disp([path '/' mapar.output '.avi'])

% Enjoy watching the video!


pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

cd(olddir)
