function mcdemo2
% This example shows how you can do various coordinate
% transformations to MoCap data and merge data
%
% Let us plot a motion-capture frame:
load mcdemodata
mcplotframe(dance1, 50,mapar);


pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
% Let us rotate 'dance1' by 90 degrees (counterclockwise) around the z
% (vertical) axis:
d1rot1 = mcrotate(dance1, 90, [0 0 1]);
close
mcplotframe(d1rot1, 50, mapar);


pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
% Next, let us rotate 'dance1' by 90 degrees (counterclockwise) around 
% the x axis:
d1rot2 = mcrotate(dance1, 90, [1 0 0]);
close
mcplotframe(d1rot2, 50, mapar);


pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
% Finally, let us rotate 'dance1' by 90 degrees (counterclockwise) around 
% the y axis:
close
d1rot3 = mcrotate(dance1, 90, [0 1 0]);
mcplotframe(d1rot3, 50, mapar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% To add data from several motion capture data structures to one
% visualization, the mctranslate and mcmerge functions are useful:
close
all = dance1; 

% translate 'd1rot1' 2000 mm to the right and merge with 'all'
% merge also the parameter structures
[all, allparams] = mcmerge(all, mctranslate(d1rot1, [2000 0 0]), mapar, mapar); 

% Same with 'd1rot2' and 'd1rot3', but with different translations
[all, allparams] = mcmerge(all, mctranslate(d1rot2, [0 0 2000]), allparams, mapar); 
[all, allparams] = mcmerge(all, mctranslate(d1rot3, [2000 0 2000]), allparams, mapar);

allparams.msize=6;
mcplotframe(all, 50, allparams);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
% Next, let us take excerpts from 'dance1' and 'dance2' and merge them
% for visualization
d1 = mctrim(dance1, 0, 2);
d2 = mctrim(dance2, 0, 2);
d2 = mctranslate(d2, [2000 0 0]);
[d, par] = mcmerge(d1, d2, mapar, mapar);
mcplotframe(d, 60, par);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Several frames can be plotted by using a vector as the second parameter
mcplotframe(d, 1:5:51, par);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% We can also plot the frames as a single figure by setting the field
% `.hold` of the parameter structure `par` to have the value 1:

par.hold=1
mcplotframe(d, 1:5:51, par);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Example 6 explains how these frames can be used to create an animation.

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
close all
