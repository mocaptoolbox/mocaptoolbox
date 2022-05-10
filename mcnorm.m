function d2 = mcnorm(d, comps)
% Calculates the norms of kinematic vectors.
%
% syntax
% n = mcnorm(d);
% n = mcnorm(d, comps);
%
% input parameters
% d: MoCap data structure
% comps: components included in the calculation (optional, default = 1:3)
%
% output
% n: norm data structure
%
% examples
% n = mcnorm(d);
% n = mcnorm(d, 1:2); % calculates norm of horizontal projection
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

if nargin==1 
    comps=1:3; 
end

d2=[];

if nargin==2
    if ~isnumeric(comps) || length(comps)>3 || max(comps)>3 || min(comps)<1
        disp([10, 'The second argument has to be numerical and cannot be longer or higher than 3 or smaller than 1.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
end


if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    d2 = d;
    d2.type = 'norm data';
    d2.data=[];
    for k=1:3:size(d.data,2)
        d2.data = [d2.data sqrt(sum(d.data(:,k+comps-1).^2,2))];
    end
elseif isnumeric(d) && mod(size(d,2),length(comps))==0
    d2=[];
    for k=1:3:size(d,2)
        d2 = [d2 sqrt(sum(d(:,k+comps-1).^2,2))];
    end
else
    disp([10, 'The first input argument has to be a variable with MoCap data structure or a numeric array.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
