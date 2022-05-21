function [xs f p1 p2] = mcgxwt(d,gxwt,cwt)
% Generalized cross-wavelet transform between two or more MoCap or Norm data structures
%
% syntax
%
% [xs f p1 p2] = mcgxwt(d1,d2)
% [xs f p1 p2] = mcgxwt(___,Name,Value)
% [xs f] = mcgxwt(d1,d2,...dN)
% [xs f] = mcgxwt(___,Name,Value)
%
% input parameters
%  d1,d2,... dN: MoCap or Norm data structures (two structures are required as a minimum)
%
%  Name-value arguments: Specify optional pairs of arguments as Name1=Value1,...,NameN=ValueN, where Name is the argument name and Value is the corresponding value. Name-value arguments must appear after other arguments, but the order of the pairs does not matter.
%   gxwt options:
%    type (optional):
%       - 'all' (default) calculates the pseudovariace for all
%          channel pairs in each wavelet tensor.
%       - 'pairwise' calculates the pseudovariance for only the pairs of
%          corresponding channels in W1 and W2 (note: can only be
%          computed when all sets have identical number of channels)
%
%   cwt options:
%    otherOpts (optional): A structure containing name-value parameters recognized by the Matlab function cwt.m, e.g.:
%     par.VoicesPerOctave = 4;
%     par.TimeBandwidth = 120;
%     [xs f p1 p2] = mcgxwt(dance1,dance2,type='pairwise',otherOpts=par);
%
% output
%
% xs = generalized cross spectrum (frequency x time)
%
% p1, p2 = projection tensors (frequency x time x channel). In this
%       implementation, projection tensors can only be computed for the
%       dyadic case (two wavelet tensors).
%
% examples
% [xs f] = mcgxwt(d1,d2,d3,d4,d5);
% [xs f] = mcgxwt(d1,d2,d3,type='all');
% [xs f p1 p2] = mcgxwt(d1,d2,otherOpts=par);
% [xs f p1 p2] = mcgxwt(d1,d2,type='pairwise',minf=0,maxf=5);
%
% comments
%
% Requires Matlab Wavelet Toolbox.
%
% The imaginary part of xs is obtained from pairwise phase
% differences.
% In- and anti-phase relationships yield
% identical imaginary parts in this implementation.
% When computing polyadic GXWT (i.e., involving more than two wavelet tensors),
% the imaginary part is not a generalization of the cross-wavelet transform.
%
% see also
% mccoupling, mcplsproj
%
% references
%
% Toiviainen, P., & Hartmann, M. (2022). Analyzing multidimensional movement interaction with generalized cross-wavelet transform. Human Movement Science, 81, 102894.
arguments (Repeating)
    d(1,1) {mustBeMocapNormSegm(d)}
end
arguments
    gxwt.type (1,1) string {mustBeMember(gxwt.type,["all","pairwise"])} = 'all'
    cwt.minf (1,1) {mustBeNonnegative} = 0;
    cwt.maxf (1,1) {mustBeNonnegative} = 10;
    cwt.otherOpts(1,1) struct
end

nsets=numel(d);
if nsets > 2 & nargout > 2
    error('Invalid number of outputs. Projection tensors can only be computed for the dyadic case (two MoCap or Norm data structures)')
end

freq = cellfun(@(x) size(x.freq,1),d,'un',0);
if numel(unique(cell2mat(freq))) ~= 1
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    error('All MoCap or Norm data structures should have the same sampling frequency')
end
cwt.fs = d{1}.freq;
datalength = cellfun(@(x) size(x.data,1),d,'un',0);
if numel(unique(cell2mat(datalength))) ~= 1
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    error('All MoCap or Norm data structures should have the same number of frames')
end

data = cellfun(@(x) x.data,d,'un',0);

if isfield(cwt,'otherOpts')
    c = namedargs2cell(cwt.otherOpts);
    for k = 1:numel(data)
        [w{k},f] = cwtensor(data{k},cwt.fs,cwt.minf,cwt.maxf,c{:});
    end
else
    for k = 1:numel(data)
    [w{k},f] = cwtensor(data{k},cwt.fs,cwt.minf,cwt.maxf);
    end
end

if nsets == 2
    [xs p1 p2] = genxwt(w,numel(w),gxwt.type{1});
else
    xs = genxwt(w,numel(w),gxwt.type{1});
end
