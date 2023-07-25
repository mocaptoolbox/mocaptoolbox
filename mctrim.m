function d2 = mctrim(d, t1, t2, ttype)
% Extracts a temporal section from a MoCap, norm, or segm data structure.
%
% syntax
% d2 = mctrim(d, t1, t2);
% d2 = mctrim(d, t1, t2, timetype);
%
% input parameters
% d: MoCap, norm, or segm data structure
% t1: start of extracted section
% t2: end of extracted section
% timetype: either 'sec' (default) or 'frame'
%
% output
% d2: MoCap, norm, or segm structure containing frames from t1 to t2 (if timetype == 'frame') or frames between t1 and t2 seconds (if timetype == 'sec') of MoCap structure d.
%
% examples
% d2 = mctrim(d, 305, 1506, 'frame');
% d2 = mctrim(d, 3, 5, 'sec');
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if nargin<4
    ttype='sec';
end

d2=[];

if nargin==4 && ~strcmp(ttype, 'sec') && ~strcmp(ttype, 'frame')
    disp([10, 'Fourth input argument unknown. Time type set to seconds.', 10])
    ttype='sec';
end

if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    if strcmp(ttype,'sec')
        t1 = round(d.freq * t1) + 1;
        t2 = round(d.freq * t2) + 1;
    end
    if t1<1 || t2 > d.nFrames || t1>t2
        disp([10, 'Time limits are out of range.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
    d2 = d;
    d2.data = d.data(t1:t2,:);
    if isfield(d.other,'quat') & ~isempty(d.other.quat)
        d2.other.quat = d.other.quat(t1:t2,:);
    end
    d2.nFrames = length(t1:t2);
elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    if strcmp(ttype,'sec')
        t1 = round(d.freq * t1) + 1;
        t2 = round(d.freq * t2) + 1;
    end
    if t1<1 || t2 > d.nFrames || t1>t2
        disp([10, 'Time limits are out of range.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
    d2 = d;
    d2.roottrans = d.roottrans(t1:t2,:);
    d2.rootrot.az = d.rootrot.az(t1:t2,:);
    d2.rootrot.el = d.rootrot.el(t1:t2,:);
    for m=1:length(d.segm)
        if ~isempty(d.segm(m).eucl)
            d2.segm(m).eucl = d.segm(m).eucl(t1:t2,:);
        end
        if ~isempty(d.segm(m).angle)
            d2.segm(m).angle = d.segm(m).angle(t1:t2,:);
        end
        if isfield(d.segm,'quat') & ~isempty(d.segm(m).quat)
            d2.segm(m).quat = d.segm(m).quat(t1:t2,:);
        end
    end
    if ~isempty(d.other.quat)
        d2.other.quat = d.other.quat(t1:t2,:);
    end
    d2.nFrames = length(t1:t2);
else
    disp([10, 'The first input argument has to be a variable with MoCap, norm, or segm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
