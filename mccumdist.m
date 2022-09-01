function d2 = mccumdist(d)
% Calculates the cumulative distance traveled by each marker.
%
% syntax
% d2 = mccumdist(d);
%
% input parameters
% d: MoCap data or norm data structure
%
% output
% d2: norm data structure
%
% comments
% If the input consists of one-dimensional data (i.e., norm data), the cumulative
% distance to the origin of the reference space/coordination system is calculated,
% which is not (necessarily) the cumulated distance traveled by the marker.
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    d2 = d;
    d2.type = 'norm data';
    d2.data = [];
    for k=1:d.nMarkers
        tmp = [zeros(1,3); abs(diff(d.data(:, 3*k+(-2:0))))];
        tmp2 = sqrt(sum(tmp.*tmp,2));
        tmp3 = cumsum(tmp2);
        d2.data = [d2.data tmp3];
    end
elseif isfield(d,'type') && strcmp(d.type, 'norm data')
    d2=d;
    d2.data = [];
    for k=1:d.nMarkers
        tmp = [zeros(1); abs(diff(d.data(:, k)))];
        tmp3 = cumsum(tmp);
        d2.data = [d2.data tmp3];
    end
else
    disp([10, 'This function only works with MoCap or norm data structures.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
