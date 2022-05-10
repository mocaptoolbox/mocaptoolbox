function [ds, pers, pows] = mcsethares(d, per, nbasis)
% Performs either an m-best or a small-to-large Sethares transform on MoCap,
% norm or segm data
% Returns the basis functions for each DOF for given periods and, with the
% m-best transform, also the powers for the respective periods.
%
% syntax
% ds = mcsethares(d, per); %small-to-large Sethares transform
% [ds, pers, pows] = mcsethares(d, per, nbasis); %m-best Sethares transform
%
% input parameters
% d: MoCap, norm or segm data structure
% per: period in frames in case of small-to-large Sethares transform
%      maximum period in frames in case of m-best Sethares transform
% nbasis: number of basis functions estimated (only for m-best Sethares transform)
%
% output
% ds: MoCap, norm or segm data structure - the only output in case of small-to-large Sethares transform
% in case of m-best Sethares transform also:
% per: best periods for each degree of freedom
% pow: powers of respective periods
%
% comments
% Dependent on the given input parameter, either the m-best or the
% small-to-large Sethares transform is chosen. See syntax above about in-
% and output argument structure.
% Uses the Periodicity Toolbox downloadable at http://eceserv0.ece.wisc.edu/~sethares/downloadper.html
% 
% see also
% mcpcaproj, mcicaproj
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland


if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    ds=[];
    pers=[];
    pows=[];
    return;
end


if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data') || strcmp(d.type, 'segm data'))
else
    disp([10, 'The first input argument has to be a variable with MoCap, norm, or segm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    ds=[];
    pers=[];
    pows=[];
    return
end

if nargin>=2 && ~isnumeric(per)
     disp([10, 'The second input argument has to be numeric.', 10]);
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     ds=[];
     pers=[];
     pows=[];
     return
end
if nargin==3 && ~isnumeric(nbasis)
     disp([10, 'The third input argument has to be numeric.', 10]);
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     ds=[];
     pers=[];
     pows=[];
     return
end


if nargin==2
    ds=s2l(d, per);
end

if nargin==3
    [ds, pers, pows]=mb(d, per, nbasis);
end


%%%%%%%%%%%%%%%%%%
function ds=s2l(d, per)

if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    
    ds = d; ds.data = zeros(per, size(d.data,2));
    for k=1:size(d.data,2)
        s=d.data(:,k);
        ms = mean(s);
        s=s-ms;
        [periodall,powersall,basall]=small2large(s,0,per);
        ds.data(:,k) = basall(end,1:per)'+ms;
    end
    
elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    ds = d; 
    ds.roottrans = zeros(per, 3);
    for kk=1:3
        s = d.roottrans(:,kk); ms = mean(s); s=s-ms;
        [periodall,powersall,basall]=small2large(s,0,per);
        ds.roottrans(:,kk) = basall(end,1:per)'+ms;
    end

    s = d.rootrot.az; ms = mean(s); s=s-ms;
    [periodall,powersall,basall]=small2large(s,0,per);
    ds.rootrot.az = basall(end,1:per)'+ms;

    s = d.rootrot.el; ms = mean(s); s=s-ms;
    [periodall,powersall,basall]=small2large(s,0,per);
    ds.rootrot.el = basall(end,1:per)'+ms;
    
    
    for k = 2:d.nMarkers
        ds.segm(k).eucl = zeros(per,3);
        for kk=1:3
            s = d.segm(k).eucl(:,kk); ms = mean(s); s=s-ms;
            [periodall,powersall,basall]=small2large(s,0,per);
            ds.segm(k).eucl(:,kk) = basall(end,1:per)'+ms;
        end
    end
    ds.nFrames = per;
end


%%%%%%%%%%%%%%%%%%%%%%
function [ds, pers, pows] = mb(d, maxper, nbasis)

if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    mp = maxper;
    pers=[]; pows=[];
    for m=1:nbasis
        ds(m) = d;
    end
    for k=1:size(d.data,2)
        s=d.data(:,k);
        ms = mean(s);
        s=s-ms;
        [per,pow,bas]=mbest(s,nbasis,mp);
        pers=[pers per']; pows=[pows pow'];
        for m=1:nbasis
            ds(m).data(:,k) = bas(m,:)'+ms;
        end
    end
    
elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    mp = round(maxper*d.freq);
    pers=[]; pows=[];
    for m=1:nbasis
        ds(m) = d;
    end
    for kk=1:3
        s = d.roottrans(:,kk); ms = mean(s); s=s-ms;
        [per,pow,bas]=mbest(s,nbasis,mp);
        for m=1:nbasis
            ds(m).roottrans(:,kk) = bas(m,:)'+ms;
        end
    end
    for k = 2:d.nMarkers
        for kk=1:3
            s = d.segm(k).eucl(:,kk); ms = mean(s); s=s-ms;
            [per,pow,bas]=mbest(s,nbasis,mp);
            pers=[pers per']; pows=[pows pow'];
            for m=1:nbasis
                ds(m).segm(k).eucl(:,kk) = bas(m,:)'+ms;
            end
        end
    end
    for m=1:nbasis
        ds(m).nFrames = d.nFrames;
    end
end
