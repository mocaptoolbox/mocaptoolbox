function mcdemo5
% This example shows how the toolbox can be used
% to calculate kinetic variables from MoCap data 
% using Dempster's body-segment model.

% Let us estimate various forms of mechanical energy
% in walking movement (variable walk1)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us first plot a MoCap frame with marker numbers:

load mcdemodata
mapar.colors = 'wkkkk';
mapar.showmnum = 1;
mapar.msize=6;
mapar.az=90;
mcplotframe(walk2,160, mapar);
set(gcf,'Position',[40 450 400 300])

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The first thing to do is to reduce the set of markers
% to make the data compatible with Dempster's model.
% This can be accomplished using the marker-to-joint
% transformation. 

% The parameters needed for this conversion
% are in the variable m2jpar:

m2jpar

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The information about which markers correspond to each joint
% is in the field m2jpar.markerNum. The names of the new
% joints are in m2jpar.markerName. 
% For instance, ...

m2jpar.markerName{1}
m2jpar.markerNum{1}

% ... the joint 'root' is obtained by calculating the
% centroid of markers 9, 10, 11 and 12

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The marker-to-joint conversion is carried out like this:

walk2j = mcm2j(walk2, m2jpar)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The parameters for the visualization of the joint
% representation are in the variable japar:

japar

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us visualize a frame from the new variable with
% marker numbers:

japar.colors = 'wkkkk';
japar.showmnum = 1;
japar.msize=6;
japar.az=90;
mcplotframe(walk2j,160, japar);
set(gcf,'Position',[40 50 400 300])

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The next step is to make a joint-to-segment transformation.
% The parameters needed for this are in the variable j2spar.

j2spar

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
% The transformation can be accomplished using the function mcj2s. 

walk2s = mcj2s(walk2j, j2spar)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The parameters for each body segment can be obtained using the
% function mcgetsegmpar:

spar = mcgetsegmpar('Dempster',[0 0 8 7 6 0 8 7 6 13 12 10 11 3 2 1 11 3 2 1]);

% The second argument in the function call associates each joint in
% walk1j and walk1s with a segment type. The numbers refer to the distal 
% joint of the respective segment. Joints that are not distal to any 
% segment have zero values. 
% Segment number values for model 'Dempster' are as follows: no parameter=0, 
% hand=1, forearm=2, upper arm=3, forearm and hand=4, upper extremity=5, 
% foot=6, leg=7, thigh=8, lower extremity=9, head=10, shoulder=11, thorax=12, 
% abdomen=13, pelvis=14, thorax and abdomen=15, abdomen and pelvis=16, 
% trunk=17, head, arms and trunk (to glenohumeral joint)=18, head, arms 
% and trunk (to mid-rib)=19.
 
% For instance, the third component, 8, tells that the body segment whose
% distal joint is joint number 3, is a 'thigh'.

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The potential energy for each body segment can now be calculated 
% as follows:

pot = mcpotenergy(walk2j, walk2s, spar);

% This is a matrix where each column corresponds to a body segment.
% The total potential energy can be plotted as follows:

figure
set(gcf,'Position',[40 450 400 300])
plot((1:walk2.nFrames)/walk2.freq, sum(pot,2))
xlabel('Time / s')
ylabel('Potential energy / W')

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The translational and rotational energy for each body segment 
% can be calculated as follows:

[trans, rot] = mckinenergy(walk2j, walk2s, spar);

% The total translational energy can be plotted as follows:

figure
set(gcf,'Position',[40 50 400 300])
plot((1:walk2.nFrames)/walk2.freq, sum(trans,2))
xlabel('Time / s')
ylabel('Translational energy / W')

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close all
