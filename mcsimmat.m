function sm = mcsimmat(d, metric)
% Calculates self-similarity matrix from MoCap or segm data.
%
% syntax
% sm = mcsimmat(d);
% sm = mcsimmat(d, metric);
%
% input parameters
% d: MoCap or segm data structure
% metric: distance metric used, see help pdist (default: cityblock)
%
% output
% sm: self-similarity matrix
%
% examples
% sm = mcsimmat(d);
% sm = mcsimmat(d, 'corr');
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if nargin==1
    metric='cityblock';
end

if nargin==2 && ~ischar(metric)
    disp([10, 'The second input argument has to be a string variable.', 10]);
    sm=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    sm = simmat(d.data, metric);
elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    tmp = [d.roottrans d.rootrot.az];
    for k = 2:d.nMarkers
        tmp = [tmp d.segm(k).eucl];
    end
    sm = simmat(tmp, metric);

else
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    sm=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


return;

%%%%%%%%%%


function mat = simmat(data, metric)

data = data(:, find(sum(isnan(data))==0));
mat = squareform(pdist(data, metric));

return
