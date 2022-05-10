function d1 = mcinitstruct(type, data, freq, markerName, fn)
% Initializes MoCap or norm data structure.
%
% syntax
% d1 = mcinitstruct;
% d1 = mcinitstruct(type);
% d1 = mcinitstruct(type, data);
% d1 = mcinitstruct(type, data, freq);
% d1 = mcinitstruct(type, data, freq, markerName);
% d1 = mcinitstruct(type, data, freq, markerName, fn);
% d1 = mcinitstruct(data, freq);
% d1 = mcinitstruct(data, freq, markerName);
% d1 = mcinitstruct(data, freq, markerName, fn);
%
% input parameters
% type: 'MoCap data' or 'norm data' (default: 'MoCap data')
% data: data to be used in the .data field of the mocap structure (default: [])
% freq: frequency / capture rate of recording (default: NaN)
% markerName: cell array with marker names (default: {})
% fn: filename (default: '')
% 
% output
% d1: mocap or norm data structure with default parameters or parameter
% adjustment according to the parameter input.
% 
% examples
% d1 = mcinitstruct;
% d1 = mcinitstruct('norm data', data);
% d1 = mcinitstruct(data, 120, markernames, 'mydata1.tsv');
% 
% comments
% default parameters (for 'MoCap data'): 
%   type: 'MoCap data'
%   filename: ''
%   nFrames: 0
%   nCameras: NaN
%   nMarkers: 0
%   freq: NaN
%   nAnalog: 0
%   anaFreq: 0
%   timederOrder: 0
%   markerName: {}
%   data: []
%   analogdata: []
%   other:
%   	other.descr: 'DESCRIPTION	--'
%   	other.timeStamp: 'TIME_STAMP	--'
%       other.dataIncluded: '3D'
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

d1=[];

if nargin==0 %nothing is given
    type='MoCap data';
    data=[];
    freq=NaN;
    markerName={};
    fn='';
end
if nargin==1
    if ischar(type) %type is given
        data=[];
        freq=NaN;
        markerName={};
        fn='';
    else
        disp([10, 'Inconsistent input arguments.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end
if nargin==2
    if ischar(type) && isnumeric(data) %type and data given
        freq=NaN;
        markerName={};
        fn='';
    elseif isnumeric(type) && isnumeric(data) %data and freq given
        freq=data;
        data=type;
        type='MoCap data';
        markerName={};
        fn='';
    else
        disp([10, 'Inconsistent input arguments.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end
if nargin==3
    if ischar(type) && isnumeric(data) && isnumeric(freq) %type, data, and freq given
        markerName={};
        fn='';
    elseif isnumeric(type) && isnumeric(data) && iscell(freq) %data, freq, and markerName given
        markerName=freq;
        freq=data;
        data=type;
        type='MoCap data';
        fn='';
    else
        disp([10, 'Inconsistent input arguments.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end
if nargin==4
    if isnumeric(type) && isnumeric(data) && iscell(freq) && ischar(markerName) %data, freq, markerName, and filename given
        fn=markerName;
        markerName=freq;
        freq=data;
        data=type;
        type='MoCap data';
    else
        disp([10, 'Inconsistent input arguments.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end


d1.type=type;
d1.filename=fn;
d1.nFrames=length(data);
d1.nCameras=NaN;
if strcmp(type,'norm data')
    d1.nMarkers=size(data,2);
else
    d1.nMarkers=size(data,2)/3;
end
d1.freq=freq;
d1.nAnalog=0;
d1.anaFreq=0;
d1.timederOrder=0;
d1.markerName=markerName;
d1.data=data;
d1.analogdata=[];
d1.other=[];

d1.other.descr='DESCRIPTION	--';
d1.other.timeStamp='TIME_STAMP	--';
d1.other.dataIncluded='3D';



if length(d1.markerName)~=d1.nMarkers && ~isempty(markerName)
    disp([10, 'Warning: Amount of marker names (markerName field) inconsistent with number of markers (nMarkers field)', 10]);
end

if strcmp(d1.type,'MoCap data') && d1.nMarkers*3~=size(d1.data,2)
    disp([10, 'Warning: Inconsistent type (MoCap data) and size of data (data and nMarkers fields)', 10]);
end

if strcmp(d1.type,'norm data') && d1.nMarkers~=size(d1.data,2)
    disp([10, 'Warning: Inconsistent type (norm data) and size of data (data and nMarkers fields)', 10]);
end

