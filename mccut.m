function [d11, d22] = mccut(d1, d2)
% Cuts two MoCap structures to the length of the shorter one.
%
% syntax
% [d11, d22] = mccut(d1, d2);
%
% input parameters
% d1, d2: MoCap or norm structures
%
% output
% d11, d22: MoCap or norm structures, one shortened and one original (both with same number of frames)
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

d11=[];
d22=[];

if nargin<1
    disp([10, 'Please enter two mocap data structures.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


if isfield(d1,'type') && strcmp(d1.type, 'MoCap data')
else disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]); 
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if isfield(d2,'type') && strcmp(d2.type, 'MoCap data')
else disp([10, 'The second input argument has to be a variable with MoCap data structure.', 10]); 
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


if d1.nFrames<d2.nFrames
    disp([10, 'd2 has been shortened.', 10]);
elseif d1.nFrames>d2.nFrames
    disp([10, 'd1 has been shortened.', 10]);
else disp([10, 'd1 and d2 have the same length.', 10]);
end

d11=d1;
d22=d2;

if d1.nFrames ~= d2.nFrames
    N = min(d1.nFrames, d2.nFrames);
    d11.data = d1.data(1:N,:);
    d22.data = d2.data(1:N,:);
    d11.nFrames = N;
    d22.nFrames = N;
end
