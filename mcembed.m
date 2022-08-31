function d2 = mcembed(d, delays,options)
%function d2 = mcembed(d, delays)
% Concatenates a MoCap or norm data structure with one or multiple time delayed copies of it.
%
% syntax
%
%  d2 = mcembed(d,delays);
%  d2 = mcembed(d,delays,'timetype','frame');
%
% input parameters
% d: MoCap or norm data structure
% delays: vector indicating extent of the delays to be applied. The length of this vector is equal to the resulting number of delayed copies of the data.
% timetype: delay given in frames ('frame') or seconds ('sec') (default: 'sec')
%
% output
% d2: MoCap or norm data structure containing time delay embedded data. Data preceding the specified delays in the time delayed copies consist of repeated copies of the first frame of the original data.
%
% examples
%
% d2 = mcembed(d,10,'timetype','frame')
% d2 = mcembed(d,10:10:120,'timetype','frame');
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland
arguments
    d
    delays
    options.timetype = 'sec'
end

if strcmpi(options.timetype,'sec')
    delays = delays*d.freq;
end

d2=d;
for k=1:length(delays)
    delayed=[repmat(d.data(1,:),delays(k),1);d.data(1:(end-delays(k)),:)];
    d2.data=[d2.data delayed];
end

d2.nMarkers=d.nMarkers*(length(delays)+1);
d2.markerName=repmat(d.markerName,length(delays)+1,1);
