function [or r2] = mcorientation(source,lmarker1,rmarker1,target,lmarker2,rmarker2)
% Calculates angles between two straight lines defined by two markers of 
% each source and target mocap structures.
%
% syntax
% d2 = mcorientation();
% d2 = mcorientation();
%
% input parameters
% source: MoCap data structure defining the source
% lmarker1, rmarker1: left and right marker numbers defining the source
% target: MoCap data structure defining the target
% lmarker2, rmarker2: left and right marker numbers defining the target
%
% output
% or: angle
% r2: distance
%
% examples
% d2 = mcorientation();
% d2 = mcorientation();
%
% comments
%
% see also
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

% TODO checks

s1=mcgetmarker(source,lmarker1);
s2=mcgetmarker(source,rmarker1);
s3=mcgetmarker(target,lmarker2);
s4=mcgetmarker(target,rmarker2);

d1=s2.data-s1.data;
v1=[-d1(:,2) d1(:,1)]; % gaze direction
[az1 r1]=cart2pol(v1(:,1),v1(:,2));

d2=(s4.data+s3.data)/2-(s1.data+s2.data)/2;
v2=[d2(:,1) d2(:,2)]; % direction to target
[az2 r2]=cart2pol(v2(:,1),v2(:,2));

or=180*(az1-az2)/pi;

