function dist = mcmarkerdist(d, m1, m2)
% Calculates the frame-by-frame distance of a marker pair.
%
% syntax
% dist = mcmarkerdist(d, m1, m2);
%
% input parameters
% d: MoCap data structure
% m1, m2: marker numbers
%
% output
% dist: column vector
%
% examples
% dist = mcmarkerdist(d, 1, 5);
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

dist=[];

if nargin<3
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    if ~isnumeric(m1) || ~isnumeric(m2) || length(m1)>1 || length(m2)>1
        disp([10, 'Marker numbers have to be single numerics.', 10]); 
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
    if m1>d.nMarkers || m2>d.nMarkers || m1<1 || m2<1 
        disp([10, 'Marker numbers out of range.', 10]); 
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return; 
    end
    c1 = 3*m1+(-2:0); c2 = 3*m2+(-2:0); 
    dist = sqrt(sum((d.data(:,c1)-d.data(:,c2)).^2,2));
else
    disp([10, 'The first input argument should be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end

