function d2 = mcaddframes(varargin)
% Duplicates frames in a given mocap structure; either last frame in the
% end, first frames in the beginning, or at a given position in the middle.
% 
% syntax
% d2 = mcaddframes(d, add);
% d2 = mcaddframes(d, add, 'timetype', 'frame', 'location', 'beginning');
% d2 = mcaddframes(d, add, 'location', 'middle', 'position', n);
% 
% input parameters
% d: MoCap or norm data structure
% add: total amount of frames to be added
% timetype: length given in frames ('frame') or seconds ('sec') (default: sec)
% location: location where frames are added: 'beginning', 'middle', or
% 'end' (default: end)
% position: position where frames are added ? only needed when using
% 'middle' as location. If timetype is set to seconds, position value
% is also treated as being in seconds.
% 
% output
% d2: MoCap or norm data structure
% 
% examples
% d2 = mcaddframes(d, 60);
% d2 = mcaddframes(d, 60, 'location', 'middle', 100);
%
% comments
% timetype, location, and position are optional. Default values are used if
% not specified.
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

d2=[];

if nargin<2
    disp([10, 'Please enter a mocap data structure and the amount of frames you want to add.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

d=varargin{1};
frames=varargin{2};
ttype=[];
loc=[];
pos=[];

if ~isnumeric(frames) || length(frames)>1 
    disp([10, 'Frame argument has to be a single numeric.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

%check which input parameter are given
if nargin>2
    for k=3:2:length(varargin)
        if strcmp(varargin{k}, 'timetype')
            ttype=varargin{k+1};
        elseif strcmp(varargin{k}, 'location')
            loc=varargin{k+1};
        elseif strcmp(varargin{k}, 'position')
            pos=varargin{k+1};
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
if strcmp(loc,'middle') && isempty(pos)
    disp([10, 'Please indicate position for frames to be added.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
elseif strcmp(loc,'middle') && ~isnumeric(pos) || length(pos)>1
    disp([10, 'Position argument has to be a numeric value.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end
if isempty(pos)
    pos=d.nFrames;
end

if isfield(d, 'type') && strcmp(d.type, 'MoCap data') || isfield(d, 'type') && strcmp(d.type, 'norm data')
    if strcmp(ttype,'sec')
        frames = round(d.freq * frames);
        pos = round(d.freq * pos)+1;
    end

    if strcmp(loc,'end')
        last=d.data(d.nFrames,:);    
        add=repmat(last, frames, 1);
        d.data = [d.data; add];
    elseif strcmp(loc,'beginning')
        first=d.data(1,:);
        add=repmat(first, frames, 1);
        d.data = [add; d.data];
    elseif strcmp(loc,'middle')
        start=d.data(pos,:);
        add=repmat(start, frames, 1);
        dd=d.data(1:pos,:);
        ddd=d.data(pos+1:d.nFrames,:);
        d.data=[dd; add; ddd];
    else disp([10, 'Input argument for location unknown.' 10])
        return
    end
    
    d.nFrames=size(d.data,1);
    d2=d;
    
else
    disp([10, 'The first input argument has to be a variable with MoCap or norm data structure.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end



