function d2 = mcconcatenate(varargin)
% Concatenates markers from different MoCap or norm data structure.
%
% syntax
% d2 = mcconcatenate(d1, mnum1, d2, mnum2, d3, mnum3, ...);
%
% input parameters
% d1, d2, d3, ...: MoCap or norm data structure
% mnum1, mnum2, mnum3, ...: vector containing the numbers of markers to be extracted 
% from the preceding MoCap structure
%
% output
% d2: MoCap or norm data structure
%
% examples
% d2 = mcconcatenate(d1, [1 3 5], d2, [2 4 6]);
% d2 = mcconcatenate(d1, 1, d2, 2, d1, 3, d3, 4, d2, 5);
%
% comments
% Each mocap structure must have a corresponding marker number or number array.
% All mocap structures must have identical frame rates. 
% If the numbers of frames are not equal, the output MoCap structure 
% will be as long as the shortest input MoCap structure. 
%
% see also
% mcgetmarker, mcmerge
%
% todo
% segment structure (requires mcgetmarker and mcmerge to accept segment data)
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland


d2=[];

%check that syntax is correct and store input to two cell arrays
%correct amount of input arguments
if mod(nargin,2) ~= 0
    disp([10, 'Amount of input arguments is odd number. Add or remove argument.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

%get mocap data structures
mocap={};
i=0;%counter
for k=1:2:nargin
    i=i+1;
    if isfield(varargin{k},'type') && (strcmp(varargin{k}.type, 'MoCap data') || strcmp(varargin{k}.type, 'norm data'))% || strcmp(varargin{k}.type, 'segm data')
        mocap{i}=varargin{k}; %store to cell array
    else
        disp([10, 'The odd input arguments should be MoCap or norm data structures.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

%get marker numbers
markers={};
i=0;%counter
for k=2:2:nargin 
    i=i+1;
    if isnumeric(varargin{k})% check it's a number or a number vector
        m=varargin{k};
        for j=1:length(m)
            if mod(m(j),1)~=0 %check that it's integer
                disp([10, 'The even input arguments should be integer numbers.', 10]);
                [y,fs] = audioread('mcsound.wav');
                sound(y,fs);
                return
            end
        end %if it "survives" the for loop, all numbers are integers!
        markers{i}=varargin{k}; %store to cell array
    else
        disp([10, 'The even input arguments should be integer numbers or integer number vectors.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

% check that marker numbers are within the range
for k=1:nargin/2
    if max(markers{k}) > mocap{k}.nMarkers 
        disp([10, 'Marker number higher than amount of markers in given mocap data.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

%concatenate by getting the markers and merging everything to a mocap structure
d2=mcgetmarker(mocap{1}, markers{1});
for k=2:nargin/2
    tmp=mcgetmarker(mocap{k}, markers{k});
    d2=mcmerge(d2, tmp);
end

