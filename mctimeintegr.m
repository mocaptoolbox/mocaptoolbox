function d2 = mctimeintegr(d, n)
% Estimates time integrals of motion capture data using the rectangle rule.
%
% syntax
% d2 = mctimeder(d);
% d2 = mctimeintegr(d, order);
%
% input parameters
% d: MoCap data structure or segm data structure
% n: order of time integral (optional, default = 1)
%
% output
% d2: MoCap data structure or segm data structure
%
% examples
% d2 = mctimeintegr(d, 2); % second-order time integral
%
% comments
% The function updates the timederorder field as follows:
% d2.timederorder = d.timederorder - order.
%
% see also
% mctimeder
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];

if nargin<2
    n=1;
end

if nargin==2 && ~isnumeric(n)
     disp([10, 'The second input argument has to be numeric.', 10]);
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     return
end


if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data')) %BBADD20150811 norm data
    % integrate MoCap data
    d2 = d;
    for m=1:n
        d2.data = cumsum(d2.data) / d.freq;
    end
    d2.timederOrder = d.timederOrder - n;
elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    % integrate segm data
    d2 = d;
    for m=1:n
        d2.roottrans = cumsum(d2.roottrans) / d.freq;
        d2.rootrot.az = cumsum(d2.rootrot.az) / d.freq;
        d2.rootrot.el = cumsum(d2.rootrot.el) / d.freq;
        for k=1:length(d.segm)
            if ~isempty(d.segm(k).eucl) d2.segm(k).eucl = cumsum(d2.segm(k).eucl) / d.freq; end
            if ~isempty(d.segm(k).angle) d2.segm(k).angle = cumsum(d2.segm(k).angle) / d.freq; end
            if ~isempty(d.segm(k).quat) d2.segm(k).quat = cumsum(d2.segm(k).quat) / d.freq; end
        end
    end
    d2.timederOrder = d.timederOrder - n;
elseif isnumeric(d)
    d2 = d;
    for m=1:n
        d2 = cumsum(d);
    end
else
    disp([10, 'The first input argument has to be a variable with MoCap, norm, or segm data structure or numeric array.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end

return
