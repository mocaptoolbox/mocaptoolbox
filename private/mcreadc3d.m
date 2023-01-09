function d = mcreadc3d(fn);

% Adjusted to use readc3d, Created by JJ Loh  2006/09/10-2008/04/10
% Departement of Kinesiology
% McGill University, Montreal, Quebec Canada
% used by permission
%
% read in mocap data using readc3d.m
% convert from readc3d structure to MoCap Toolbox structure


% read in data from */mocaptoolbox/private/readc3d.m
data = readc3d(fn);

% create MoCap structure
d.type = 'MoCap data';
d.filename = fn;
d.nFrames = data.Header.EndVideoFrame;
d.nCameras = 0;
d.nMarkers = size(fieldnames(data.VideoData),1);
d.freq = data.Header.VideoHZ;
d.nAnalog = data.NumAnalogue;
d.anaFreq= [];
d.timederOrder = 0;
d.markerName = [];
d.data = [];
d.analogdata = data.AnalogData;
d.other = [];


% organize data
pos = {'xdata','ydata','zdata'};

for x=1:size(fieldnames(data.VideoData),1)
    d.markerName{x,1} = data.VideoData.(strcat('channel',num2str(x))).label;
    for y=1:3, d_tmp(:,y) = data.VideoData.(strcat('channel',num2str(x))).(pos{y}); end
    d.data = [d.data d_tmp]; clear d_tmp
    d.other.residualerror = data.VideoData.(strcat('channel',num2str(x))).residual;
end

d.other.event = [];
d.other.parametergroup = data.Parameter;
d.other.camerainfo = [];
disp(strcat(fn,' loaded'))

if data.Header.EndVideoFrame ~= length(d.data) %BBFIX20141202 Optitrack apparently has issues with this.
    disp([10, 'Note: d.nFrames does not match length of d.data. d.nFrames changed accordingly.', 10])
    d.nFrames = length(d.data);
end
