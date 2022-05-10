function p = mcinitm2jpar
% Initialises the parameter structure for marker-to-joint mapping.
%
% syntax
% p = mcinintm2jpar;
%
% input parameters
% (none)
%
% output
% p: m2jpar structure
%
% comments
% See the explanation of the m2jpar structure. The initialized values are as follows:
%   type: 'm2jpar'
%   nMarkers: 0
%   markerNum: {}
%   markerName: {}
% The fields p.nMarkers, p.markerNum and p.markerName have to be entered manually.
% 
% see also
% mcm2j
% 
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

p.type = 'm2jpar';
p.nMarkers = 0;
p.markerNum = cell(0);
p.markerName = cell(0);
