function [xs p1 p2] = genxwt(varargin)
% Generalized cross-wavelet transform between sets of multivariate time series
%
% syntax
% xs = genxwt(W,<N>,<type>)
% xs = genxwt(W1,W2,...,<type>)
%
% input parameters
%
% W =  wavelet tensors obtained by the function cwtensor. W can
%       either be a set of wavelet tensors concatenated
%       channel-wise % (W = cat(3,W1,W2,...)) or a cell array of
%       wavelet tensors (W{1}=W1; W{2}=W2; W{3}=W3).
%
% W1,W2,... = wavelet tensors obtained by the function cwtensor
%
% N = (optional)
%       integer scalar (greater than 1) specifying number of sets
%       (for sets with identical number of channels) or integer
%       vector specifying number of channels in each set. Note: N
%       is required when using concatenated tensors as input
%       (cat(3,W1,W2,...)).
%
% TYPE = (optional) {'all','pairwise'}
%       'all' (default) calculates the pseudovariace for all
%       channel pairs in each wavelet tensor.
%       'pairwise' calculates the pseudo-variance for only the pairs of
%       corresponding channels in W1 and W2 (note: can only be
%       computed when all sets have identical number of channels)
%
% OUTPUT
%
% xs = generalized cross spectrum (frequency x time)
%
% p1, p2 = projection tensors (frequency x time x channel). In this
%       implementation, projection tensors can only be computed for the
%       dyadic case (two wavelet tensors).
%
% comments
%
% cwtensor.m requires Matlab Wavelet Toolbox.
%
% - The imaginary part of xs is obtained from pairwise phase
% differences.
% - In this implementation, in- and anti-phase relationships yield
% identical imaginary parts.
% - When computing polyadic GXWT (i.e., involving more than two wavelet tensors),
% the imaginary part is not a generalization of the cross-wavelet transform.
%
% see also
% mcgxwt, cwtensor
%
% references
%
% Toiviainen, P., & Hartmann, M. (2022). Analyzing multidimensional movement interaction with generalized cross-wavelet transform. Human Movement Science, 81, 102894.
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland
if numel(varargin) > 1
    if ischar(varargin{end})
        type = varargin{end};
        narg = 1;
    else
        type = 'all';
        narg = 0;
    end

    if isscalar(varargin{end-narg}) || isvector(varargin{end-narg})
        N = varargin{end-narg};
        narg = narg+1;
    end
    d = varargin(1:end-narg);
else
    type = 'all';
    d = varargin(1);
end

if numel(d) > 1
    w = cat(3,d{:});
    if ~exist('N','var')
        N = cellfun(@(x) size(x,3),d);
    end
elseif isa(d{1},'double')
    w = d{1};
    if ~exist('N','var')
        error('N is required when when using concatenated tensors as input')
    end
else
    w = cat(3,d{1}{:});
    if ~exist('N','var')
        N = cellfun(@(x) size(x,3),d{1});
    end
end

M=size(w,3); % number of channels in concatenated tensor

if ~isscalar(N) & numel(unique(N)) == 1
    N = numel(N);
end
if isscalar(N)
    nc = M/N; % number of channels per set
    if mod(M,N) ~= 0
        error(['Number of channels per set must be an integer value.'])
    end
end

if strcmpi(type,'all')
    if isscalar(N)
        for k = 1:N
            wsi{k} = ones(nc); % within-subject interaction blocks
        end
    else
        for k = 1:numel(N)
            wsi{k} = ones(N(k));
        end
    end
    ews = logical(~blkdiag(wsi{:})); % exclude within-subject interactions from outer product
    mask = triu(ews); % discard duplicates
elseif strcmpi(type,'pairwise') & isscalar(N)
    ind=1:M;
    mat=ind-ind';
    mask=mod(mat,nc)==0 & mat>0;

elseif strcmpi(type,'pairwise') & ~isscalar(unique(N))
    error('''Pairwise'' option can only be used when all sets have identical number of channels')
else
    error('Allowed options for TYPE are ''all'' and ''pairwise''')
end

xs=zeros(size(w,1),size(w,2));
for fr=1:size(w,1) % for each frequency
    for t=1:size(w,2) % for each time point
        tf = squeeze(w(fr,t,:)); % tensor fiber
        Z0=tf*tf';
        Z = Z0(mask); % Instantaneous cross spectrum
        xs(fr,t)=sqrt(mean(Z.*Z)); % sqrt of pseudovariance
        if (N == 2 | numel(N) == 2) & nargout > 1
            % Calculate projections
            S = abs(real(Z0*exp(-i*angle(xs(fr,t)))));
            if strcmp(type,'all')
                p1(fr,t,:)=mean(S,2);
                p2(fr,t,:)=mean(S,1);
            else  % strcmp(type,'pairwise')
                p1(fr,t,:)=diag(S);
                p2(fr,t,:)=diag(S);
            end
        end
    end
end
