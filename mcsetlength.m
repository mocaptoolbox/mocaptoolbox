function d2 = mcsetlength(varargin)
% Sets mocap data to the length given.
%
% syntax
% d2 = mcsetlength(d, n)
% d2 = mcsetlength(d, n, 'timetype', 'sec')
% d2 = mcsetlength(d, n, 'position', 'location')
%
% input parameters
% d: MoCap or norm data structure
% n: new length of mocap data
% timetype: length given in frames ('frame') or seconds ('sec') (default: sec)
% location: position where to add or trim frames ('beginning' or 'end' ? default: end)
%
% output
% d2: MoCap or norm data structure
%
% examples
% d2 = mcsetlength(d, 1200);
% d2 = mcsetlength(d, n, 'timetype', 'sec');
% d2 = mcsetlength(d, 1200, 'location', 'beginning');
%
% comments
% If the given length is less than the number of frames in the mocap data,
% the data will be trimmed to the given length from either beginning or end.
% If the given length is more than the number of frames in the mocap data,
% data will be added by replicating with first or last frame.
%
% see also
% mcaddframes, mctrim
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d2=[];

if nargin<2
    disp([10, 'Not enough input arguments.', 10]);
    return
end

d=varargin{1};
n=varargin{2};
ttype=[];
loc=[];

%check which input parameter are given
if nargin>2
    for k=3:2:length(varargin)
        if strcmp(varargin{k}, 'timetype')
            ttype=varargin{k+1};
        elseif strcmp(varargin{k}, 'location')
            loc=varargin{k+1};
        else
            str=sprintf('Input argument %s unknown. Default value is used.', varargin{k});
            disp([10, str, 10])
        end
    end
end

%default values
if isempty(ttype)
    ttype='sec';
end
if isempty(loc)
    loc='end';
end


if isfield(d, 'type') && strcmp(d.type, 'MoCap data') || isfield(d, 'type') && strcmp(d.type, 'norm data')
    if isnumeric(n) && length(n)==1
        if strcmp(ttype,'sec')
            n = round(d.freq * n);
        end
        if strcmp(loc,'beginning')
            if n<d.nFrames
                d2=mctrim(d, n, d.nFrames, 'frame'); %trim
            else
                d2=mcaddframes(d, n-d.nFrames, 'timetype', 'frame', 'location', 'beginning'); %add
            end
        else %loc=end
            if n<d.nFrames
                d2=mctrim(d, 1, n, 'frame'); %trim
            else
                d2=mcaddframes(d, n-d.nFrames, 'timetype', 'frame'); %add
            end
        end
    else disp([10, 'The second input argument has to be a numeric value.' 10])
    end
else disp([10, 'The first input argument has to be a variable with MoCap or norm data structure.' 10])
end
