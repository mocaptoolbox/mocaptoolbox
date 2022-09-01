function d2 = mctranslate(d, X)
% Translates motion-capture data by a vector.
%
% syntax
% d2 = mctranslate(d, X);
%
% input parameters
% d: MoCap structure or data matrix
% X: translation vector
%
% output
% d2: MoCap structure or data matrix
%
% examples
% d2 = mctranslate(d, [0 1000 0]);
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if ~isnumeric(X) || length(X)~=3
    disp([10, 'The second argument has to be numeric and have a length of 3.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    d2 = d;
    d2.data(:,1:3:end) = d2.data(:,1:3:end) + X(1);
    d2.data(:,2:3:end) = d2.data(:,2:3:end) + X(2);
    d2.data(:,3:3:end) = d2.data(:,3:3:end) + X(3);
elseif isnumeric(d)
    d2 = d;
    d2(:,1:3:end) = d(:,1:3:end) + X(1);
    d2(:,2:3:end) = d(:,2:3:end) + X(2);
    d2(:,3:3:end) = d(:,3:3:end) + X(3);
else
    disp([10, 'The first input argument has to be a variable with MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
