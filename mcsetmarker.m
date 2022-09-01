function d2 = mcsetmarker(d, d1, mnum)
% Replaces a subset of markers in an existing mocap or norm structure.
%
% syntax
% d2 = mcgetmarker(d_orig, d_repl, mnum);
%
% input parameters
% d_orig: MoCap or norm data structure (the one to be changed)
% d_repl: MoCap or norm data structure (the one that contains the
% replacement data). The data set must have the same amount of markers as
% indicated in mnum.
% mnum: vector containing the marker numbers to be replaced in the original data set
% (order as in replacement mocap structure)
%
% output
% d2: MoCap structure
%
% examples
% d2 = mcsetmarker(d, d1, [1 3 5]);
%
% comments
% Use mcgetmarker to shorten the replacing data set to fit the mnum vector.
% If the resulting mocap structure shall contain more markers than the
% original, the data will be appended at the specified marker number.
% Possible in-between markers will be set to NaN. Empty marker names will be set
% to EMPTY and can be adapted manually if desired.
%
% see also
% mccombine, mcgetmarker
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];

%Check that mnum equals data in d1
if length(mnum) ~= d1.nMarkers %FIX BB20130210
    disp([10, 'Replacement mocap structure d1 must contain the same amount of markers as indicated in mnum.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if isfield(d,'type') && strcmp(d.type, 'MoCap data') && isfield(d1,'type') && strcmp(d1.type, 'MoCap data')
    if min(mnum)<1 || max(mnum)>d.nMarkers
        disp([10, 'Marker numbers higher than in original data structure.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end

    d2=d;
    for k=1:length(mnum)
        d2.data(:, mnum(k)*3-2:mnum(k)*3)=d1.data(:,k*3-2:k*3);
    end

    if max(mnum)>d.nMarkers %FIX BB20130121
        d2.nMarkers=max(mnum);
        d2.markerName(d.nMarkers+1:d2.nMarkers)={'EMPTY'}; %set all new markers to empty
        d2.markerName(mnum)=d1.markerName; %set marker names to names that are known from d1 (all markers) %FIX BB20130210
        d2.markerName(1:d.nMarkers)=d.markerName;% set back to names from d
        for k=d.nMarkers+1:d2.nMarkers
            if d2.data(:,k*3)==0
                d2.data(:,k*3-2:k*3)=NaN;
            end
        end
    end

elseif isfield(d,'type') && strcmp(d.type, 'norm data') && isfield(d1,'type') && strcmp(d1.type, 'norm data')
    if min(mnum)<1 || max(mnum)>d.nMarkers
        disp([10, 'Marker numbers higher than in original data structure.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end

    d2=d;
    for k=1:length(mnum)
        d2.data(:, mnum(k))=d1.data(:,k);
    end

    if max(mnum)>d.nMarkers %FIX BB20130121
        d2.nMarkers=max(mnum);
        d2.markerName(d.nMarkers+1:d2.nMarkers)={'EMPTY'}; %set all new markers to empty
        d2.markerName(mnum)=d1.markerName; %set marker names to names that are known from d1 (all markers) %FIX BB20130210
        d2.markerName(1:d.nMarkers)=d.markerName;% set back to names from d
        for k=d.nMarkers+1:d2.nMarkers
            if d2.data(:,k)==0
                d2.data(:,k)=NaN;
            end
        end
    end

else
    disp([10, 'The first two input arguments have to be a variable with MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
