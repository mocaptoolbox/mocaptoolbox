function d2=mcsort(d, srt)
% Sorts mocap data according to marker names (alphanumerical or according
% to given numeric or cell array indicating marker numbers or markers names
% as to how the output data is to be sorted).
%
% syntax
% d2=mcsort(d)
% d2=mcsort(d, srt)
%
% input parameters
% d: MoCap data structure
% srt: numeric or cell array containing markers numbers or marker names
% (optional)
%
% output
% d2: reordered mocap data structure
%
% examples
% d2=mcsort(d)
% d2=mcsort(d, [1:5 7 6 9 8 10:20]);
% d2=mcsort(d, d1.markerName);
%
% comments
% If the sort variable is not given, the data will be sorted alphanumerical
% according to the marker names.
% The number of items in the sort array has to match the number of markers
% in the input mocap data structure.
%
% Script developed by Federico Visi, Kristian Nymoen, and Birgitta Burger
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];
a=0;

if ~isfield(d,'type') || ~strcmp(d.type, 'MoCap data')
    disp([10, 'The first input argument has to be a variable with MoCap data structure.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

a = mcinitm2jpar;
a.nMarkers = d.nMarkers;

if nargin==1 %sort alphanumerical
    [~, f] = sort(d.markerName);
    a.markerName = d.markerName(f);
    a.markerNum = num2cell(f)';
    d2 = mcm2j(d,a);
end


if nargin==2
    if length(srt) == d.nMarkers %match size
        if ~iscell(srt) && ~isnumeric(srt)
            disp([10, 'The second input parameter has to be a numeric array or a cell array.' 10])
            [y,fs] = audioread('mcsound.wav');
            sound(y,fs);
            return
        end

        if iscell(srt) %cell array with markers names
            if size(srt,1)==1 %check format
                srt=srt';
            end

            tmp1=sort(srt); %check spelling
            tmp2=sort(d.markerName);
            if sum(strcmp(tmp1, tmp2)) == d.nMarkers
                [~, idx] = ismember(srt,d.markerName); %convert cell array into numerical
                srt=idx;
            else disp([10, 'The marker names in the sort array have to be spelled in the same way as in the input mocap data structure.' 10])
                [y,fs] = audioread('mcsound.wav');
                sound(y,fs);
                return
            end
        end

        if isnumeric(srt) %numeric array with marker numbers (also converted cell array)
            if max(srt)==d.nMarkers %numbers are in correct range (highest value of srt should not be higher than no of markers)
                if isequal(unique(srt,'stable'),srt )%check for double numbers
                    for k=1:length(srt)
                        a.markerName(k,1)=d.markerName(srt(k));
                    end
                    a.markerNum = num2cell(srt)';
                    d2 = mcm2j(d,a);
                else disp([10, 'The sort array contains double values.' 10])
                    [y,fs] = audioread('mcsound.wav');
                    sound(y,fs);
                end
            else disp([10, 'The highest value given in the sort array is higher than the marker number in the mocap data structure.' 10])
                [y,fs] = audioread('mcsound.wav');
                sound(y,fs);
            end
        end
    else disp([10, 'The second input parameter has to match the number of markers in the input mocap data structure.' 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
    end
end
