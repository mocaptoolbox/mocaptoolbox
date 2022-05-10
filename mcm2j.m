function d2 = mcm2j(d, par)
% Performs a marker-to-joint mapping.
%
% syntax
% d2 = mcm2j(d, par);
%
% input parameters
% d: MoCap structure
% par: m2jpar structure
%
% output
% d2: MoCap structure
% 
% comments
% The fields the fields par.nMarkers, par.markerNum and par.markerName have to be entered manually.
% See the explanation of the m2jpar structure.
% 
% see also 
% mcinitm2jpar
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland


d2=[];
if isfield(d,'type') && strcmp(d.type, 'MoCap data') && isfield(par,'type') && strcmp(par.type, 'm2jpar')
    d2 = d;
    d2.nMarkers = length(par.markerNum);
    d2.markerName = par.markerName;
    d2.data = [];
    for k=1:par.nMarkers
        d2.data = [d2.data mean(d.data(:,3*par.markerNum{k}-2),2) mean(d.data(:,3*par.markerNum{k}-1),2)...
            mean(d.data(:,3*par.markerNum{k}),2)];
    end
else
    disp([10, 'The first input argument should be a variable with MoCap data structure.']);
    disp(['The second input argument should be a variable with m2jpar data structure.',10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end

