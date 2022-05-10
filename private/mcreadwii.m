function d = mcreadwii(fn)
% function d = mcreadwii(fn)
%
% Reads data files saved with the WiiDataCapture application,
% parses, and interpolates to 10 ms intervals.
%
% Input parameter: 
% fn = file name (if not given, opens a file open dialog window)
%
% Output parameters:
% d = mocap data structure


q = load(fn);

if size(q,1)==1 % old version of WiiDataCapture
	w = reshape(q',4,size(q,2)/4)';
else
	w = q;
end

t = w(:,1); % time column
t2 = (0:10:max(t))';
w2 = interp1(t,w,t2,'spline');

size(w2)

if size(w,2)==4
    data = w2(:,2:4)-repmat(mean(w2(:,2:4)), size(w2,1),1);
    
else data = w2(:,2:7)-repmat(mean(w2(:,2:7)), size(w2,1),1); %BBFIX 20110120: read 6D data produced by WiiDataCapture for the MotionPlus extention
end
%data=w2(:,2:7);% 7: for 6-DOF Qualisys-to-MaxMSP streaming

d.type = 'MoCap data';
d.filename = fn;
d.nFrames = size(data,1);
d.nCameras = [];
d.nMarkers = 1;
d.freq = 100;
d.nAnalog = 0;
d.anaFreq = [];
d.timederOrder = 2; % acceleration data
d.markerName = {'wii'}; %FIX BB 20130217
d.data = data; 
d.analogdata = [];
d.other = [];

