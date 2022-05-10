function dn = mcsegmangle(d, m1, m2)
% calculates the angles between two markers.
%
% syntax
% dn = mcsegmangle(d, m1, m2);
%
% input parameters
% d: MoCap data structure
% m1: marker one
% m2: marker two
%
% output
% dn: norm data structure containing the three angles 
% 
% examples
% dn = mcsegmangle(d, 1, 2);
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

dn=[];

if nargin<3
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if ~isnumeric(m1) || ~isnumeric(m2) || length(m1)>1 || length(m2)>1
    disp([10, 'Marker number arguments have to be single numerics.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if min(m1)<1 || max(m1)>d.nMarkers ||  min(m2)<1 || max(m2)>d.nMarkers 
    disp([10, 'Marker numbers are out of range.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end


if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    
    d1=mcgetmarker(d, [m1 m2]);
    
    x=d1.data(:,4)-d1.data(:,1);
    y=d1.data(:,5)-d1.data(:,2);
    z=d1.data(:,6)-d1.data(:,3);
    
    dn=d1;
    
    dn.type='norm data';
    dn.nMarkers=3;
    dn.markerName=[{'x-angle'}; {'y-angle'}; {'z-angle'}];
    
    dn.data=[atan(x./sqrt(y.*y+z.*z+eps)) atan(y./sqrt(x.*x+z.*z+eps)) atan(z./sqrt(y.*y+x.*x+eps))];
    
else
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end