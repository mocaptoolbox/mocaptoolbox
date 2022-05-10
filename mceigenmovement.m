function e = mceigenmovement(d, eigind, len, per)
% Constructs eigenmovements using PCA and a scaled sinusoidal projection.
%
% syntax
% e = mceigenmovement(d);
% e = mceigenmovement(d, eigind);
% e = mceigenmovement(d, eigind, len);
% e = mceigenmovement(d, eigind, len, per);
%
% input parameters
% d: MoCap or segm data structure
% eigind (optional): selected eigenmovements (if not given, projections onto the first PCs
% that contain a total of 90% of the variance are returned)
% len (optional): length in seconds (default 0.5 sec)
% per (optional): period in seconds (default 0.5 sec)
%
% output
% e: vector of MoCap or segm data structures
% 
% examples
% e = mceigenmovement(d);
% e = mceigenmovement(d, 1:3);
% e = mceigenmovement(d, 1:4, 2);
% e = mceigenmovement(d, 1:2, 1.2, 0.6);
% 
% comments
% The sinusoidal projections are scaled to match the RMS amplitudes of the PC projections 
% of respective degrees of freedom.
% 
% see also
% mcpcaproj
% 
% ? Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland


if nargin<4
    per=0.5; 
end
if nargin<3 
    len=0.5; 
end

if nargin>1
    if ~isnumeric(eigind) || ~isnumeric(per) || ~isnumeric(len)
        disp([10, 'Input arguments two to four (if given) have to be numeric.', 10]);
        e=[];
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end 

if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data') || strcmp(d.type, 'segm data'))
    p = mcpca(d);
    if nargin<2
        cl = cumsum(p.l);
        ind = min(find(cl>0.9));
        eigind = 1:ind;
        disp([10, 'Projecting onto ' num2str(ind) ' first PCs', 10])
    end
    lenf=round(len*d.freq); perf=round(per*d.freq);
    proj = sin(2*pi*(0:(lenf-1))/perf);
    for k=1:length(eigind)
        scale(k) = sqrt(mean(p.c(eigind(k),:).*p.c(eigind(k),:)));
    end
    for k=1:length(eigind)
        e(k) = mcpcaproj(d,eigind(k),scale(k)*proj);
    end
else 
    disp([10, 'The first input argument has to be a variable with MoCap data structure.', 10]);
    e=[];
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
