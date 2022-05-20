function [r par] = mccoupling(mc1, mc2, par)
% Computes a number of coupling indices between two sets of mocap data using Principal Component Analysis (PCA) and Canonical Component Analysis (CCA).
%
% syntax
% r = mccoupling(mc1, mc2);
% r = mccoupling(___,Name,Value) specifies options using one or more name-value pair arguments in addition to the input arguments in the previous syntax.
%
% input parameters
% d1, d2: MoCap data structures
%
% Name-value arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%  t1: start of analysis window in seconds
%  t2: end of analysis window  in seconds
%  pcind: indices for PCs retained (default: 1:5)
%  scale: scaling for visualizing (default: .3)
%  proj: function for back-projection of canonical coefficients to marker space (default: sin(2*pi*linspace(0,1,121))')
%  binsizetype: (optional, if not given, uses the Freedman-Diaconis rule for computing mutual information)
%   'number': sets number of bins for marginal distributions
%   'size': sets size of bins for marginal distributions
%  binvalue: value associated with binsizetype
%
% output
% r: data structure containing coupling indices and related information:
%  dpj: vector of MoCap, norm or segm data structures containing the projections (joint PCA)
%  p: PCA parameter structure (joint PCA)
%  omegaj: joint omega complexity (joint PCA)
%  dp: vector of MoCap, norm or segm data structures containing the projections (individual PCA)
%  p: PCA parameter structure (individual PCA)
%  pccorr: correlation matrix based on PC scores (joint PCA)
%  omega: individual omega complexities based on PC scores (individual PCA)
%  pcmutinf: mutual information of PC scores (individual PCA)
%  xcorr: cross-correlations between PC scores (individual PCA)
%  xcmax: maximum values of each cross-correlation (individual PCA)
%  xcmaxlag: optimal lag of each cross-correlation (individual PCA)
%  phdiff: instantaneous phase difference between PC scores (individual PCA)
%  orderpar: order parameter based on phase differences between PC scores (individual PCA)
%  meanphdiff: mean phase difference between between PC scores  (individual PCA)
%  cc: canonical coefficients of each set of mocap data (CCA)
%  r: canonical correlations (CCA)
%  ccmc1: vector of MoCap, norm or segm data structures containing the projections for the first Mocap data structure (CCA)
%  ccmc2: vector of MoCap, norm or segm data structures containing the projections for the second Mocap data structure (CCA)
% examples
%
% r = mccoupling(mc1, mc2, t1=0, t2=10);
% r = mccoupling(mc1, mc2, pcind=1:3);
%
% comments
%
% see also
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

arguments
    mc1
    mc2
    par.t1; % start of analysis window
    par.t2; % end of analysis window
    par.pcind=1:5; % indices for PCs retained
    par.scale=.3; % scaling for visualizing
    par.proj=sin(2*pi*linspace(0,1,121))'; % back-projection function
    par.binsizetype;
    par.binvalue;
end

% Trim
if isfield(par,'t2')
    mc1=mctrim(mc1,par.t1,par.t2);
    mc2=mctrim(mc2,par.t1,par.t2);
end

% Joint PCA
mc=mcmerge(mc1,mc2);
[r.dpj,r.pj] = mcpcaproj(mc,par.pcind);

% Joint omega complexity
r.omegaj=exp(-sum(r.pj.l.*log(max(r.pj.l,eps))));

% Individual PCAs
[r.dp{1},r.p{1}] = mcpcaproj(mc1,par.pcind);
[r.dp{2},r.p{2}] = mcpcaproj(mc2,par.pcind);

% Individual  omega complexities
r.omega(1)=exp(-sum(r.p{1}.l.*log(max(r.p{1}.l,eps))));
r.omega(2)=exp(-sum(r.p{2}.l.*log(max(r.p{2}.l,eps))));

% CCA on selected PC scores
[r.cc{1},r.cc{2},r.r,r.cs{1},r.cs{2}]=canoncorr(r.p{1}.c(par.pcind,:)',r.p{2}.c(par.pcind,:)');

% Project CCs back to marker space
for ind2=par.pcind
    orig=(r.p{1}.q(:,par.pcind)*r.p{1}.c(par.pcind,:))'; % player 1
    proj=repmat(par.proj,1,size(mc1.data,2)).*repmat(r.cc{1}(:,ind2)'*r.p{1}.q(:,par.pcind)',size(par.proj,1),1); % use a sinusoid
    proj=par.scale*proj.*repmat(std(orig),size(par.proj,1),1)./(repmat(std(proj),size(par.proj,1),1)+eps); % scale projection
    proj=proj+repmat(r.p{1}.meanx,size(proj,1),1); % add mean back to data
    r.ccmc1(ind2)=mc1; r.ccmc1(ind2).data=proj;

    orig=(r.p{2}.q(:,par.pcind)*r.p{2}.c(par.pcind,:))'; % player 2
    proj=repmat(par.proj,1,size(mc1.data,2)).*repmat(r.cc{1}(:,ind2)'*r.p{2}.q(:,par.pcind)',size(par.proj,1),1); % use a sinusoid
    proj=par.scale*proj.*repmat(std(orig),size(par.proj,1),1)./(repmat(std(proj),size(par.proj,1),1)+eps); % scale projection
    proj=proj+repmat(r.p{2}.meanx,size(proj,1),1); % add mean back to data
    r.ccmc2(ind2)=mc2; r.ccmc2(ind2).data=proj;
end

% Coupling strength
% Correlation of PC scores
r.pccorr=corr(r.p{1}.c(par.pcind,:)',r.p{2}.c(par.pcind,:)');
% Mutual information of PC scores
if isfield(par,'binvalue')
    r.pcmutinf=mutinfo(r.p{1}.c(par.pcind,:)',r.p{2}.c(par.pcind,:)',par.binsizetype, par.binvalue);
else
    r.pcmutinf=mutinfo(r.p{1}.c(par.pcind,:)',r.p{2}.c(par.pcind,:)');
end
% Phase relationship
% cross-correlation on PC scores
r.xcorr=zeros(2*mc1.nFrames-1,length(par.pcind),length(par.pcind));
for k1=par.pcind
    for k2=par.pcind
        r.xcorr(:,k1,k2)=xcorr(r.p{1}.c(k1,:)',r.p{2}.c(k2,:)','coeff');
        [r.xcmax(k1,k2) tmp]=max(r.xcorr(:,k1,k2));
        r.xcmaxlag(k1,k2)=(tmp-mc1.nFrames-1)/mc1.freq;
    end
end

% Hilbert transform on PC scores, instantaneous phase difference, order parameter
r.phdiff=zeros(mc1.nFrames,length(par.pcind),length(par.pcind));
for k1=par.pcind
    for k2=par.pcind
        z1=angle(hilbert(r.p{1}.c(k1,:)'));
        z2=angle(hilbert(r.p{2}.c(k2,:)'));
        r.phdiff(:,k1,k2)=z1-z2;
        circmean=sum(exp(i*r.phdiff(:,k1,k2)))/mc1.nFrames;
        r.orderpar(k1,k2)=abs(circmean);
        r.meanphdiff(k1,k2)=angle(circmean);
    end
end
