function d = mcreademg(fn)
% Reads emg files in .tsv format recorded with the Mega EMG system using QTM.
% 
% syntax
% d = mcreademg(fn);
% 
% input parameters
% fn: File name; tsv format (norm data structure)
% 
% output
% d: norm data structure
% 
% examples
% d = mcreademg('filename.tsv');
% 
% see also
% mcfilteremg
% 
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland


ifp = fopen(fn);
if ifp<0
    disp(['Could not open file ' fn]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

d.type = 'norm data';
d.filename = fn;
d.timederOrder = 0;

s=fscanf(ifp,'%s',1);
s=fscanf(ifp,'%s',1); d.nFrames = str2num(s);
s=fscanf(ifp,'%s',1);
s=fscanf(ifp,'%s',1); d.nMarkers = str2num(s);
s=fscanf(ifp,'%s',1);
s=fscanf(ifp,'%s',1); d.freq = str2num(s);
s=fscanf(ifp,'%s',1);
s=fscanf(ifp,'%s',1); d.other.nCalcChan = str2num(s);
s=fgetl(ifp);
s=fgetl(ifp); d.other.timeStamp=s;
s=fscanf(ifp,'%s',1);
s=fscanf(ifp,'%s',1); d.other.firstSample = str2num(s);
fgetl(ifp);
s=fscanf(ifp,'%s',1);
s=fscanf(ifp,'%s',1); 
s=fscanf(ifp,'%s',1); 
s=fscanf(ifp,'%s',1); d.other.dataIncluded = s;

s=fscanf(ifp,'%s',1); % 20080811 fixed bug that prevented reading non-annotated tsv files
tmp=fgetl(ifp); % 'MARKER_NAMES'
d.markerName=cell(d.nMarkers,1);
if length(tmp)>14 % if marker names given
    s=sscanf(tmp,'%s',1);
    d.markerName = strread(tmp,'%[^\n\r\t]');
end
% end 20080811 fix

% CHANNEL_GAIN	1	1	1	1	1	1	1	1
% FP_LOCATION
% FP_CAL
% FP_GAIN
fgetl(ifp);
fgetl(ifp);
fgetl(ifp);
fgetl(ifp);


d.data=NaN*ones(d.nFrames, d.nMarkers);
tmp=textscan(ifp,'%f','delimiter','\t');
tmp2=tmp{1};

tmp2 = tmp2(1:(d.nMarkers*floor(length(tmp2)/d.nMarkers)));
d.nFrames=length(tmp2)/d.nMarkers;
d.data = reshape(tmp2',d.nMarkers,d.nFrames)';
fclose(ifp);
