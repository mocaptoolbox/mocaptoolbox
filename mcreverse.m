function d2 = mcreverse(d, x)
% Reverses dimensions of MoCap data.
%
% syntax
% d2 = mcreverse(d, x);
%
% input parameters
% d: MoCap structure or data matrix
% x: reverse vector (set 1 for each dimension to be reversed, otherwise 0)
%
% output
% d2: MoCap structure or data matrix
%
% examples
% d2 = mcreverse(d, [0 0 1]);
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland


d2=[];

if nargin<=1
    disp([10, 'Please enter the reverse vector.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

[s1,s2] = size(x);
if (s1~=1) || (s2~=3)
    disp([10, 'Please enter data for three dimensions, e.g., [1 0 0].', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if (x(1)~=0) && (x(1)~=1) || (x(2)~=0) && (x(2)~=1) || (x(3)~=0) && (x(3)~=1)
    disp([10, 'Please enter only 1 or 0, e.g., [1 0 0].', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

x(x==1)=-1;
x(x==0)=1;

X=x;


if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    d2 = d;
    d2.data(:,1:3:end) = d2.data(:,1:3:end) * X(1);
    d2.data(:,2:3:end) = d2.data(:,2:3:end) * X(2);
    d2.data(:,3:3:end) = d2.data(:,3:3:end) * X(3);
elseif isnumeric(d) && mod(size(d,2),3)==0 && ~isempty(d)
    d2 = d;
    d2(:,1:3:end) = d(:,1:3:end) * X(1);
    d2(:,2:3:end) = d(:,2:3:end) * X(2);
    d2(:,3:3:end) = d(:,3:3:end) * X(3);
    
else disp([10, 'The first input argument has to be a variable with MoCap data structure or a numeric matrix (3*x columns).' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end

