function [or r2] = mcorientation(source,lmarker1,rmarker1,target,lmarker2,rmarker2)
% Calculates horizontal orientation of a segment with respect to the location of another segment. For each frame, mcorientation obtains the horizontal angle between a line perpendicular to a segment defined by two markers of a source MoCap structure and a line connecting the mean locations of source and target MoCap structure segments.
%
% syntax
% [or r2] = mcorientation(source,lmarker1,rmarker1,target,lmarker2,rmarker2)
%
% input parameters
% source: MoCap data structure defining the source
% lmarker1, rmarker1: left and right marker numbers defining the source
% target: MoCap data structure defining the target
% lmarker2, rmarker2: left and right marker numbers defining the target
%
% output
% or: horizontal angle (in degrees and in the interval [-180,180]) quantifying orientation of source segment with respect of location of target segment
% r2: horizontal distance between mean locations of source and target segment
%
% examples
% The function can be used to determine whether a dancer is oriented towards another dancer. See the following example:
%
% load mcdemodata
% d1 = dance1; % source MoCap data structure
% d2 = dance2 % target MoCap data structure
% d1j = mcm2j(d1, m2jpar); % marker-to-joint mapping (source)
% d2j = mcm2j(d2, m2jpar); % marker-to-joint mapping (target)
% root = find(matches(d1j.markerName,'root')); % get marker numbers for root, left hip, and right hip
% lhip = find(matches(d1j.markerName,'lhip'));
% rhip = find(matches(d1j.markerName,'rhip'));
% d1jl = mc2local(d1j,root,[lhip, rhip]); % set the origin of the source to the root marker and rotate the data to have a frontal view with respect to hips
% d2jl = mc2local(d2j,root); % set the origin of the target to the root marker
% d2jlt = mctranslate(d2jl, [2000 0 0]); % translate the target by two meters to the right
% mcorientation(d1jl,lhip,rhip,d2jlt,lhip,rhip)' % orientation of the hips of source with respect to the hips of the target is always 90 degrees (i.e., irrespective of the rotation of the target)
% [d3 par]=mcmerge(d1jl,d2jlt,japar,japar); % merge the data
% par.markercolors([[lhip;rhip];[lhip;rhip]+d2jlt.nMarkers],:) = repmat([1 1 0],4,1); % use colors to identify dancers' hips
% par.el = 90; %set the elevation parameter in the animpar structure so as to get a bird's-eye view
% mcanimate(d3,par); % the animation shows that the hips of the source dancer (left side) are oriented at 90 degrees with respect to the hips of the target dancer (right side)
%
% comments
%
% see also
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

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
