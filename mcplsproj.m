function [dp1,dp2,p1,p2,sv] = mcplsproj(d1,d2, par)
% Performs a Projection to Latent Structures (PLS) on two MoCap, norm or segm data structures and projects the data onto selected components.
%
% syntax
% [d1p,d2p, p1,p2] = mcplsproj(d1,d2);
% [d1p,d2p, p1,p2] = mcplsproj(___,Name,Value) specifies options using one or more name-value pair arguments in addition to the input arguments in the previous syntax.
%
% input parameters
% d1: MoCap, norm or segm data structure
% d2: MoCap, norm or segm data structure
%
% Name-value arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%
% ncomp (optional): number of PLS components (if not given, selects all components)
% proj (optional): projection function (if not given, the PLS component projections of the data are used)
%
% output
% dp1: vector of MoCap, norm or segm data structures for d1
% dp2: vector of MoCap, norm or segm data structures for d2
% p1 and p2: PLS parameter structures containing the following fields for d1 and d2, respectively:
%  l: PLS loadings for each component
%  s: PLS scores for each component
% sv: diagonal matrix of singular values
%
%
% examples
% [dp1,dp2,p1,p2,sv] = mcplsproj(d1,d2);
% [dp1,dp2,p1,p2,sv] = mcplsproj(d1,d2,ncomp=2);
%
% see also
% mcpcaproj, mcicaproj, mccoupling
%
% references
% Hartmann, M., Mavrolampados, A., Allingham, E., Carlson, E., Burger, B., & Toiviainen, P. (2019). Kinematics of perceived dyadic coordination in dance. Scientific Reports, 9(1), 1-14.
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland
arguments
    d1 (1,1) {mustBeMocapNormSegm(d1)}
    d2 (1,1) {mustBeMocapNormSegm(d2)}
    par.ncomp (1,1) {mustBePositive} =  min(size(d1.data,2),size(d2.data,2))
    par.proj
end
ncomp = par.ncomp;
[p1 p2 sv] = mcpls(d1,d2,ncomp);

for k=1:ncomp
    pc1 = p1.l(:,k);
    pc2 = p2.l(:,k);
    if nargin<3
        proj1 = p1.s(:,k);
        proj2 = p2.s(:,k);
    end
    if strcmp(d1.type, 'MoCap data') | strcmp(d1.type, 'norm data') && strcmp(d2.type, 'MoCap data') | strcmp(d2.type, 'norm data')
    dp1(k) = d1;
    dp2(k) = d2;
    dp1(k).data = repmat(p1.mean,size(proj1,2),1)+(proj1*pc1');
    dp2(k).data = repmat(p2.mean,size(proj2,2),1)+(proj2*pc2');
    end
    if strcmp(d1.type, 'segm data')
        tmp = repmat(p1.mean,size(proj1,1),1)+(proj1*pc1');
        dp1(k).roottrans = tmp(:,1:3);
        dp1(k).rootrot.az = tmp(:,4);
        for m=2:d1.nMarkers
            dp1(k).segm(m).eucl = tmp(:,3*m+(-1:1));
        end
        dp1(k).nFrames = size(tmp,1);
    else
        dp1(k).nFrames = size(dp1(k).data,1);
    end
    if strcmp(d2.type, 'segm data')
        tmp = repmat(p2.mean,size(proj2,1),1)+(proj2*pc2');
        dp2(k).roottrans = tmp(:,1:3);
        dp2(k).rootrot.az = tmp(:,4);
        for m=2:d2.nMarkers
            dp2(k).segm(m).eucl = tmp(:,3*m+(-1:1));
        end
        dp2(k).nFrames = size(tmp,1);
    else
        dp2(k).nFrames = size(dp2(k).data,1);
    end
end
