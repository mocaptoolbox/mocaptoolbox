function p = mcica(d, pcs, ics);
% Performs an Independent Components analysis on MoCap, norm or segm data
% 
% syntax
% p = mcpca(d, pcs, ics);
% 
% input parameters
% d: MoCap, norm or segm data structure
% pcs: number of PCs entered into ICA
% ics: number of ICs estimated
% 
% output
% p: structure containing the following fields:
%   icasig: independent components
%   A: mixing matrix
%   W: separation matrix
%   meanx: mean vector of variables
%
% note:
% uses the fastICA algorithm, implemented in the fastICA Toolbox
%
% © Part of the Motion Capture Toolbox, Copyright ©2008, 
% University of Jyvaskyla, Finland

if isfield(d,'type') & (strcmp(d.type, 'MoCap data') | strcmp(d.type, 'norm data'))
    [p.icasig, p.A, p.W] = fastica(d.data', 'lastEig', pcs, 'numOfIC', ics);
    p.meanx = mean(d.data,1);
elseif isfield(d,'type') & strcmp(d.type, 'segm data')
    tmp = d.roottrans;
    for k = 2:d.nMarkers
        tmp = [tmp d.segm(k).eucl];
    end
    [p.icasig, p.A, p.W] = fastica(tmp', 'lastEig', pcs, 'numOfIC', ics);
    p.meanx = mean(tmp,1);
end
