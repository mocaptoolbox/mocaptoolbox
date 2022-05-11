function [r par] = mccoupling(mc1, mc2, par)
% computes a number of coupling indices between mocap data
% 
% syntax
% r = mccoupling(mc1, mc2, par);
% 
% input parameters
% d1, d2: MoCap data structures
% par: parameter file
% 
% output
% r: data structure containing coupling indices and related information
%
% comments
%
% see also
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

if nargin==2 par=mcinitcouplingpar; end

% Trim
if par.t2>0
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
    proj=repmat(par.myproj,1,size(mc1.data,2)).*repmat(r.cc{1}(:,ind2)'*r.p{1}.q(:,par.pcind)',size(par.myproj,1),1); % use a sinusoid
    proj=par.scale*proj.*repmat(std(orig),size(par.myproj,1),1)./(repmat(std(proj),size(par.myproj,1),1)+eps); % scale projection
    proj=proj+repmat(r.p{1}.meanx,size(proj,1),1); % add mean back to data
    r.ccmc1(ind2)=mc1; r.ccmc1(ind2).data=proj;
    
    orig=(r.p{2}.q(:,par.pcind)*r.p{2}.c(par.pcind,:))'; % player 2
    proj=repmat(par.myproj,1,size(mc1.data,2)).*repmat(r.cc{1}(:,ind2)'*r.p{2}.q(:,par.pcind)',size(par.myproj,1),1); % use a sinusoid
    proj=par.scale*proj.*repmat(std(orig),size(par.myproj,1),1)./(repmat(std(proj),size(par.myproj,1),1)+eps); % scale projection
    proj=proj+repmat(r.p{2}.meanx,size(proj,1),1); % add mean back to data
    r.ccmc2(ind2)=mc2; r.ccmc2(ind2).data=proj;
end

% Coupling strength
% Correlation of PC scores
r.pccorr=corr(r.p{1}.c(par.pcind,:)',r.p{2}.c(par.pcind,:)');
% Mutual information of PC scores
r.pcmutinf=mutinfo(r.p{1}.c(par.pcind,:)',r.p{2}.c(par.pcind,:)',par.binsizetype, par.binvalue);

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


