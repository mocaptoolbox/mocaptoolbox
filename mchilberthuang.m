function hh = mchilberthuang(d, N)
% Performs a Hilbert-Huang transform of order N on MoCap, norm or segm data.
%
% syntax
% hh = mchilberthuang(d, N);
%
% input parameters
% d: MoCap, norm or segm data structure
% N: order of the H-H transform
%
% output
% hh: vector of MoCap, norm or segm data structures containing H-H transforms
%
% comments
% See help hilberthuang
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland


if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    hh=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end
if ~isnumeric(N)
     disp([10, 'Second input argument has to be numeric.', 10]);
     hh=[];
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     return
end


if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    for k=1:N
        dmean = mean(d.data);
        [h0, h1] = hilberthuang(d.data);
        hh(k)=d;
        hh(k).data = h0 + repmat(dmean, d.nFrames, 1);
        d = hh(k);
        d.data=h1;
    end

elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    for k=1:N
        mat = [d.roottrans d.rootrot.az];
        for m = 2:d.nMarkers
            mat = [mat d.segm(m).eucl];
        end
        dmean = mean(mat);
        [h0, h1] = hilberthuang(mat);
        h = h0 + repmat(dmean, d.nFrames, 1);
        hh(k) = d;
        hh(k).roottrans = h(:,1:3);
        hh(k).rootrot.az = h(:,4);
        for m=2:d.nMarkers
            hh(k).segm(m).eucl = h(:,3*m+(-1:1));
        end
        d = hh(k);
        h = h1 + repmat(dmean, d.nFrames, 1);
        d.roottrans = h(:,1:3);
        d.rootrot.az = h(:,4);
        for m=2:d.nMarkers
            d.segm(m).eucl = h(:,3*m+(-1:1));
        end

    end
else
    disp([10, 'The first input argument has to be a variable with MoCap, norm or segm data structure.', 10]);
    hh=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
