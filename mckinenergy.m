function [trans, rot] = mckinenergy(dv, segd, segmpar)
% Estimates the instantanous kinetic energy of each body segment.
%
% syntax
% [te, re] = mckinenergy(dv, segd, segmpar);
%
% input parameters
% dv: MoCap data structure
% segd: segm data structure calculated from dv
% segmpar: segmpar structure (see mcgetsegmpar)
%
% output
% te: matrix containing translational energy for each body segment
% re: matrix containing rotational energy for each body segment
%
% examples
% segd = mcj2s(d, j2spar);
% spar = mcgetsegmpar('Dempster', segmnum);
% [te, re] = mckinenergy(d, segd, spar);
%
% comments
% The energy for a given segment is in the column corresponding to the number 
% of the distal joint of the respective segment.
%
% see also
% mcj2s, mcgetsegmpar, mcpotenergy
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

if nargin<3
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    trans=[];
    rot=[];
    return;
end

trans = zeros(dv.nFrames,dv.nMarkers); 
rot = trans;

if isfield(dv,'type') && strcmp(dv.type, 'MoCap data') && ...
        isfield(segd,'type') && strcmp(segd.type, 'segm data') &&...
        isfield(segmpar,'type') && strcmp(segmpar.type, 'segmpar')
    % do something
    if dv.timederOrder == 0 
        dv = mctimeder(dv); 
    end

    for k=1:dv.nMarkers
        if segd.parent(k)>0
            i1 = 3*k + (-2:0);
            i2 = 3*segd.parent(k) + (-2:0);
            distv=dv.data(:,i1); 
            proxv=dv.data(:,i2);
            % linear velocity of COG
            cogv = mcnorm(proxv + (distv-proxv)*segmpar.comprox(k))/1000;
            % translational energy
            trans(:,k) = 0.5 * 60 * segmpar.m(k) * cogv.^2;
            % angular velocity
            vang = mcnorm(distv-proxv)/segd.segm(k).r;
            % rotational energy
            rot(:,k) = 0.5 * 60 * segmpar.m(k) * (segd.segm(k).r*segmpar.rogcg(k)/1000).^2 * vang.*vang;
        end
    end
    
else
    disp([10, 'The first input argument should be a variable with MoCap data structure.']);
    disp('The second input argument should be a variable with segm data structure.');
    disp(['The third input argument should be a variable with segmpar data structure.',10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    trans=[];
    rot=[];
end