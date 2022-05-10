function mcdemo1
% This example shows how you can read MoCap files into Matlab and
% edit and visualize the data
%
% The .mat file 'mcdemodata.mat' contains some motion capture data
% and associated parameter files.

load mcdemodata
whos

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Variable walk1 is a mocap structure:

walk1

% Let us look if there are any missing data in the variable walk1:

[mf, mm, mgrid] = mcmissing(walk1);
h=figure, set(h,'Position',[40 200 560 420])
subplot(3,1,1), bar(mf), xlabel('Marker'), ylabel('Num. of Missing frames')
subplot(3,1,2), bar(mm), xlabel('Frame'), ylabel('Num. of Missing markers')
subplot(3,1,3), imagesc(-mgrid'), colormap gray, xlabel('Frame'), ylabel('Marker')

% Markers 2 and 6 have missing frames. 

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clf
clc
% The missing data can be filled using the mcfillgaps function:
walk1 = mcfillgaps(walk1, 100);

[mf, mm, mgrid] = mcmissing(walk1);
subplot(3,1,1), bar(mf), xlabel('Marker'), ylabel('Num. of Missing frames')
subplot(3,1,2), bar(mm), xlabel('Frame'), ylabel('Num. of Missing markers')
subplot(3,1,3), imagesc(-mgrid'), colormap gray, xlabel('Frame'), ylabel('Marker')

% The variable walk1 has no more missing frames.

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
close(h)
clc
% Marker location data can be plotted as a function of time using the
% mcplottimeseries function:

% for example, plotting marker 3, dimension 3:
mcplottimeseries(walk1, 3, 'dim', 3) 

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% plotting markers 4, 8, & 12, dimension 3, frames on x-axis:
mcplottimeseries(walk1, [4 8 12], 'dim', 3, 'timetype', 'frame') 

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% plotting markers 4, 8, & 12, dimension 3, combined into one plot:
mcplottimeseries(walk1, [4 8 12], 'dim', 3, 'plotopt', 'comb') 

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% plotting markers 4, 8, & 12, dimensions 1:3, label on y-axis set, 
% marker names instead of numbers
mcplottimeseries(walk1, [4 8 12], 'dim', 3, 'label', 'mm', 'names', 1) 

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% using markers names instead of numbers in function call, dimensions 1:3
mcplottimeseries(walk1, {'Head_BR','Sternum','Hip_BR'}, 'dim', 1:3) 

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% Marker locations in single frames can be plotted using the mcplotframe
% command (this command plots the (x,z) projection of the markers:
mcplotframe(walk1, 160);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% This uses the default settings for the animation parameters:
mcinitanimpar

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% To get a visualisation that is easier to understand, the markers should be connected. 
% The variable mapar ... 
mapar

% ... contains the connection matrix:
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

mapar.conn'
% It also has a smaller screensize than the default:
mapar.scrsize

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Using the mapar variable, we get the following visualization:

mcplotframe(walk1, 160, mapar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% We can add marker numbers to the plot by setting:
mapar.showmnum = 1;
mcplotframe(walk1, 160, mapar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% Different colors can be used:
mapar.colors='wbgcr';
mcplotframe(walk1, 160, mapar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% ... and the connector widths and marker sizes can be adjusted:
mapar.msize=6;
mapar.cwidth = 3;
mcplotframe(walk1, 160, mapar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
clc

% The viewing azimuth and elevation can be changed:
mapar.az = 45;
mapar.el = 20;
mcplotframe(walk1, 160, mapar);


pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
close
return
