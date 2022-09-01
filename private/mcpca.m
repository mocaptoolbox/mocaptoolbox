function p = mcpca(d);
% Performs a Principal Components analysis on MoCap, norm or segm data
%
% syntax
% pc = mcpca(d);
%
% input parameters
% d: MoCap, norm or segm data structure
%
% output
% pc: structure containing the following fields:
%   l: proportion of variance contained in each PC
%   q: PC vectors (columns)
%   c: PC projections (rows)
%   meanx: mean vector of variables
%
% © Part of the Motion Capture Toolbox, Copyright ©2022,
% University of Jyvaskyla, Finland

if isfield(d,'type') & (strcmp(d.type, 'MoCap data') | strcmp(d.type, 'norm data'))
    [p.l, p.q, p.c, p.meanx] = mypca(d.data);



elseif isfield(d,'type') & strcmp(d.type, 'segm data')
    tmp = [d.roottrans d.rootrot.az];
    for k = 2:d.nMarkers
        tmp = [tmp d.segm(k).eucl];
    end
    [p.l, p.q, p.c, p.meanx] = mypca(tmp);

end
