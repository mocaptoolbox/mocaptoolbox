function p = mcinitj2spar
% Initialises the parameter structure for joint-to-segment mapping.
% 
% syntax
% p = mcinitj2spar;
%
% input parameters
% (none)
%
% output
% p: j2spar structure
%
% comments
% See explanation about the j2spar structure. The initialized values are as follows:
%   type: 'j2spar'
%   rootMarker: 0
%   frontalPlane: [1 2 3]
%   parent: []
%   segmentName: {}
% The fields p.parent and p.segmentName have to be entered manually.
% 
% see also
% mcj2s
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

p.type = 'j2spar';
p.rootMarker = 0;
p.frontalPlane = [1 2 3];
p.parent = [];
p.segmentName = cell(0);
