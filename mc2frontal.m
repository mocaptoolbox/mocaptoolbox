function [d2 theta] = mc2frontal(d, m1, m2, method)
% Rotates MoCap data to have a frontal view with respect to a pair of markers.
%
% syntax
% d2 = mc2frontal(d, m1, m2);
% d2 = mc2frontal(d, m1, m2, method);
%
% input parameters
% d: MoCap data structure or data matrix
% m1, m2: numbers of the markers that define the frontal plane
% method: rotation method, possible values:
%   'mean' (default) rotates data in all frames with the same angle to have
%       frontal view with respect to the mean locations of markers m1 and m2
%   'frame' rotates each frame separately to have a frontal view with
%       respect to the instantaneous locations of markers m1 and m2; with this
%       value, each individual frame is rotated as well
%
% output
% d2: MoCap data structure or data matrix
% theta: rotation angle(s)
%
% examples
% d2 = mc2frontal(d, 3, 7);
% d2 = mc2frontal(d, 3, 7, 'frame');
%
% comments
% The frontal plane is defined by the temporal mean of markers m1 and m2.
% See manual / function reference for visual example.
%
% see also
% mcrotate
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if nargin<4
    method = 'mean';
end

if nargin<3
    disp([10, 'mc2frontal needs at least three input parameters.' 10])
    d2=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if ~isnumeric(m1) || ~isnumeric(m2) || length(m1)>1 || length(m2)>1
    disp([10, 'Marker number arguments have to be single numerics.' 10])
    d2=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

d2=d;

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    dat = d.data;
elseif isnumeric(d)
    dat = d;
else disp([10, 'The first input argument has to be a variable with MoCap data structure or a data matrix.', 10]);
    d2=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end




if strcmp(method, 'mean')
    tmp = dat(:,[3*m1+(-2:0) 3*m2+(-2:0)]);
    x1 = mcmean(tmp(:,1));
    y1 = mcmean(tmp(:,2));
    x2 = mcmean(tmp(:,4));
    y2 = mcmean(tmp(:,5));
    [th,r] = cart2pol(x1-x2,y1-y2);
    dat2 = mcrotate(dat, 180-180*th/pi, [0 0 1]);
    theta=180-180*th/pi;
elseif strcmp(method, 'frame')
    dat2 = zeros(size(dat));
    for k=1:size(dat,1)
        tmp = dat(k,[3*m1+(-2:0) 3*m2+(-2:0)]);
        x1 = tmp(:,1);
        y1 = tmp(:,2);
        x2 = tmp(:,4);
        y2 = tmp(:,5);
        [th,r] = cart2pol(x1-x2,y1-y2);
        %dat2(k,:) = mccenter(mcrotate(dat(k,:), -180*th/pi, [0 0 1]));
        dat2(k,:) = mcrotate(dat(k,:), 180-180*th/pi, [0 0 1],[0.5*(x1+x2) 0.5*(y1+y2) 0]);
        theta(k)=180-180*th/pi;
    end
else disp([10, 'Method argument unknown.', 10]);
    d2=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    d2.data = dat2;
else
    d2 = dat2;
end
