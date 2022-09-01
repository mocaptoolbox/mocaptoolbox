function [XL,YL,XS,YS,SV] = symmpls(X,Y,ncomp)
% Computes symmetric Projection to Latent Structures (PLS) between two multivariate sets of data
%
% syntax
%
% input parameters
%
% X: first set of data
% Y: second set of data
% ncomp: number of PLS components
%
% output
%
% XL: PLS loadings for each component (first set of data)
% YL: PLS loadings for each component (second set of data)
% XS: PLS scores for each component (first set of data)
% YS: PLS scores for each component (first set of data)
% SV: diagonal matrix of singular values
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland
if nargin==2
    ncomp=min(size(X,2),size(Y,2)),
end

X=X-mean(X); %center
Y=Y-mean(Y); %center

S=X'*Y; % matrix multiplication
[W,TH,C]=svd(S,0);

XL=W(:,1:ncomp);
YL=C(:,1:ncomp);
XS=X*XL;
YS=Y*YL;
SV=diag(TH);
