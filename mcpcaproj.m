function [dp, p] = mcpcaproj(d, pcind, proj)
% Performs a Principal Components analysis on MoCap, norm or segm data
% and projects the data onto selected components.
%
% syntax
% [dp, p] = mcpcaproj(d);
% [dp, p] = mcpcaproj(d, pcind);
% [dp, p] = mcpcaproj(d, pcind, proj);
%
% input parameters
% d: MoCap, norm or segm data structure
% pcind (optional): selected Principal Components (if not given, projections onto the first PCs
%   that contain a total of 90% of the variance are returned)
% proj (optional): projection function (if not given, the PC projections of
%   the data in d are used)
%
% output
% dp: vector of MoCap, norm or segm data structures
% p: PCA parameter structure containing the following fields:
%    l: proportion of variance contained in each PC
%    q: PC vectors (columns)
%    c: PC projections (rows)
%    meanx: mean vector of variables
%
% examples
% [dp, p] = mcpcaproj(d);
% [dp, p] = mcpcaproj(d, 1:3);
% [dp, p] = mcpcaproj(d, 1:3, sin(2*pi*0:60/60);
%
% see also
% mcicaproj, mcsethares
%
% references
% Burger, B., Saarikallio, S., Luck, G., Thompson, M. R., & Toiviainen, P. (2012).
% Emotions Move Us: Basic Emotions in Music Influence People's Movement to Music.
% In Proceedings of the 12th International Conference on Music Perception and
% Cognition (ICMPC) / 8th Triennial Conference of the European Society for the
% Cognitive Sciences of Music (ESCOM). Thessaloniki, Greece.
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

if nargin==2
    if ~isnumeric(pcind)
        disp([10, 'Second input argument has to be numeric.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        dp=[];
        p=[];
        return
    end
end


if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    p = mcpca(d);
    if nargin<2
        cl = cumsum(p.l);
        ind = min(find(cl>0.9));
        pcind = 1:ind;
        disp(['Projecting onto ' num2str(ind) ' first PCs'])
    end
    for k=1:length(pcind)
        pc = p.q(:,pcind(k));
        if nargin<3
            proj = p.c(pcind(k),:);
        end
        dp(k) = d;
        dp(k).data = repmat(p.meanx,size(proj,2),1)+(proj'*pc');
        dp(k).nFrames = size(dp(k).data,1);
    end


elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    p = mcpca(d);
    if nargin<2
        cl = cumsum(p.l);
        ind = min(find(cl>0.9));
        pcind = 1:ind;
        disp(['Projecting onto ' num2str(ind) ' first PCs'])
    end
    for k=1:length(pcind)
        pc = p.q(:,pcind(k));
        if nargin<3
            proj = p.c(pcind(k),:);
        end
        dp(k) = d;
        tmp = repmat(p.meanx,size(proj,2),1)+(proj'*pc');
        dp(k).roottrans = tmp(:,1:3);
        dp(k).rootrot.az = tmp(:,4);
%        dp(k).roottrans = zeros(size(tmp(:,1:3)));
%        dp(k).rootrot.az = zeros(size(tmp(:,1:3)));
        for m=2:d.nMarkers
            dp(k).segm(m).eucl = tmp(:,3*m+(-1:1));
        end
        dp(k).nFrames = size(tmp,1);
    end

    else
        disp([10, 'The first input argument has to be a variable with MoCap, norm or segment data structure.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        dp=[];
        p=[];

end
