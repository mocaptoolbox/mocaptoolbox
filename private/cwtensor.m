function [w,f] = cwtensor(d,FS,MINF,MAXF,varargin)
% Generate a frequency x time x channel wavelet tensor from a multivarate time series
%
% syntax
% [w,f] = cwtensor(d,FS,MINF,MAXF,varargin);
%
% input parameters
%
% d: multivariate signal (time x channel)
% FS: sampling rate in Hz
% MINF: minimum frequency included in Hz
% MAXF: maximum frequency included in Hz
% varargin: any input parameters recognized by the Matlab function cwt.m
%
% output
%
% w = wavelet tensor (frequency x time x channel)
% f = frequencies of the wavelet transform
%
% examples
%
% commments
%
% Requires Matlab Wavelet Toolbox.
%
% see also
% mcgxwt, cwtensor
%
% references
%
% Toiviainen, P., & Hartmann, M. (2022). Analyzing multidimensional movement interaction with generalized cross-wavelet transform. Human Movement Science, 81, 102894.
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

for k=1:size(d,2)
    [w0 f0]=cwt(d(:,k),FS,varargin{:});
    w1=w0(f0>MINF & f0<MAXF,:);
    f=f0(f0>MINF & f0<MAXF);
    if k==1 % allocate
        w=zeros(size(w1,1),size(w1,2),size(d,2));
    end
    w(:,:,k)=w1;
end
