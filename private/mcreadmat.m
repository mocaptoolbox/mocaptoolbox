function d = mcreadmat(fn)
% function d = mcreadmat(fn)
%
% Reads data files saved as .mat file as exported from QTM.
%
% Input parameter: 
% fn = file name (if not given, opens a file open dialog window)
%
% Output parameters:
% d = mocap data structure

% Author: Erwin Schoonderwaldt
% Version history
% - Created March 2011

try
    S=load(fn);
catch
    error('Could not open file %s',fn)
end

% Parse S
sflds=fieldnames(S);
if length(sflds)>1
    error('Only one variable (struct) is expected in a .mat file exported by QTM.')
else
    qtm=S.(sflds{1});
    clearvars('S') % Free up some memory
end

% Check if the structure is conform to expectation (as exported by QTM)
if ~(...
        isfield(qtm,'Frames') && ... % should contain Frames
        isfield(qtm,'FrameRate') && ... should contain FrameRate
        isfield(qtm,'Trajectories')) % Should contain Trajectories
    error('Unexpected data format in file %s.\nMake sure to use a .mat file exported by QTM.',fn)
end

% Create output structure d
d.type = 'MoCap data';
d.filename = fn;

d.nFrames = qtm.Frames;
d.nCameras = 0; % Information not exported
d.nMarkers = qtm.Trajectories.Labeled.Count;
d.freq = qtm.FrameRate;
if ~isfield(qtm,'Analog')
    d.nAnalog = 0;
    d.anaFreq = 0;
else
    d.nAnalog = qtm.Analog.NrOfChannels;
    d.anaFreq = qtm.Analog.Frequency;
end
d.timederOrder = 0; % Position data
d.markerName = qtm.Trajectories.Labeled.Labels';

% Convert labeled trajectories (multidimensional array) to d.data matrix (nFrames x 3*nMarkers)
d.data=reshape(permute(qtm.Trajectories.Labeled.Data(:,1:3,:),[3 2 1]),d.nFrames,3*d.nMarkers);
d.residual = reshape(permute(qtm.Trajectories.Labeled.Data(:,4,:),[3 2 1]),d.nFrames,d.nMarkers);

% Write analog data
if isfield(qtm,'Analog')
    d.analogInfo=rmfield(qtm.Analog,'Data');
    d.analogdata = qtm.Analog.Data';
else
    d.analogdata = [];
end

% - SMPTETimecode
if isfield(qtm,'SMPTETimecode')
    d.SMPTETimecode = qtm.SMPTETimecode;
end

% Other information
% - Original QTM file
d.other.QTMFile = qtm.File; 
