function r = mcrotationrange(d, m1, m2)
% Calculates the rotation range between two markers.
%
% syntax
% r = mcrotationrange(d, m1, m2);
%
% input parameters
% d: MoCap data structure
% m1: marker one
% m2: marker two
%
% output
% r: rotation range (the higher the value, the more rotation)
%
% examples
% r = mcrotation(d, 13, 17);
%
% references
% Burger, B., Saarikallio, S., Luck, G., Thompson, M. R. & Toiviainen, P. (2013).
% Relationships between perceived emotions in music and music-induced movement.
% Music Perception 30(5), 519-535.
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

r=[];

if nargin<3
    disp([10, 'Please enter a mocap data structure and two markers numbers.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
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
    tmp = mcgetmarker(d,[m1 m2]);
    tmp2=tmp.data(:,4:5)-tmp.data(:,1:2);
    [th,~]=cart2pol(tmp2(:,1),tmp2(:,2)); % convert to polar coordinates
    thu=unwrap(th);
    r=max(thu)-min(thu);
else
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
