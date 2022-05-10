function d2 = mcreorderdims(d, dims)
% Reorders the Euclidean dimensions in motion capture data.
%
% syntax
% d2 = mcreorderdims(d, dims);
%
% input parameters
% d: MoCap structure
% dims: vector containing the new order of dimensions
%
% output
% d2: MoCap structure
%
% examples
% d2 = mcreorderdims(d, [1 3 2]);
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

d2 = [];

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if ~isnumeric(dims) || length(dims)~=3 || max(dims)>3 || min(dims)<1
     disp([10, 'The second input argument has to contain three numerics in the range of 1 to 3.', 10]);
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     return
end


if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    d2 = d;
    i2=[];
    for k=1:d.nMarkers
        i2=[i2 dims+3*k-3];
    end
    d2.data = d.data(:,i2);
else
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
