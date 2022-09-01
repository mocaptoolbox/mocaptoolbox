function [p1 p2 sv] = mcpls(d1, d2, ncomp);
% Performs a Projection to Latent Structures (PLS) on two MoCap, norm or segm data structures
%
% syntax
% [p1,p2] = mcpls(d1,d2);
%
% input parameters
% d1: MoCap, norm or segm data structure
% d2: MoCap, norm or segm data structure
% ncomp: number of PLS components (optional)
%
% output
% p1 and p2: PLS parameter structures containing the following fields for d1 and d2, respectively:
%  l: PLS loadings for each component
%  s: PLS scores for each component
%  mean: mean across rows in d1 (or d2)
% sv: diagonal matrix of singular values
%
% examples
%
% see also
% mcpca, mccoupling
%
% references
% Hartmann, M., Mavrolampados, A., Allingham, E., Carlson, E., Burger, B., & Toiviainen, P. (2019). Kinematics of perceived dyadic coordination in dance. Scientific Reports, 9(1), 1-14.
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland
if isfield(d1,'type') & isfield(d2,'type') & (strcmp(d1.type, 'MoCap data') | strcmp(d1.type, 'norm data')) & (strcmp(d2.type, 'MoCap data') | strcmp(d2.type, 'norm data'))
    if nargin > 2
        [p1.l,p2.l,p1.s,p2.s sv] = symmpls(d1.data,d2.data,ncomp);
    else
        [p1.l,p2.l,p1.s,p2.s sv] = symmpls(d1.data,d2.data);
    end
    p1.mean = mean(d1.data);
    p2.mean = mean(d2.data);

elseif (isfield(d1,'type') & strcmp(d1.type, 'segm data')) & (isfield(d2,'type') & strcmp(d2.type, 'segm data'))
    tmp1 = [d1.roottrans d1.rootrot.az];
    tmp2 = [d2.roottrans d2.rootrot.az];
    for k = 2:d1.nMarkers
        tmp1 = [tmp1 d1.segm(k).eucl];
    end
    for k = 2:d2.nMarkers
        tmp2 = [tmp2 d2.segm(k).eucl];
    end
    if nargin > 2
        [p1.l,p2.l,p1.s,p2.s sv] = symmpls(tmp1,tmp2,ncomp);
    else
        [p1.l,p2.l,p1.s,p2.s sv] = symmpls(tmp1,tmp2);
    end
    p1.mean = mean(tmp1);
    p2.mean = mean(tmp2);
else
    error('The first and second input arguments have to be variables with MoCap, norm or segment data structures. If either d1 or d2 is a segment data structure, the other variable should be of the same type')
end
