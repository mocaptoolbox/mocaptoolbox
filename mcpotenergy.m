function pe = mcpotenergy(d, segd, segmpar)
% Estimates the instantanous potential energy of each body segment.
%
% syntax
% pe = mcpotenergy(d, segd, segmpar)
%
% input parameters
% d: MoCap data structure
% segd: segm data structure calculated from d
% segmpar: segmpar structure (see mcgetsegmpar)
%
% output
% pe = matrix containing potential energy values for each body segment
%
% examples
% segd = mcj2s(d, j2spar);
% spar = mcgetsegmpar('Dempster', segmnum);
% pe = mckinenergy(d, segd, spar);
%
% comments
% The energy for a given segment is in the column corresponding to the number of the distal joint 
% of the respective segment.
%
% see also
% mcj2s, mcgetsegmpar, mckinenergy
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

pe = zeros(d.nFrames,d.nMarkers);
if isfield(d,'type') && strcmp(d.type, 'MoCap data') && ...
        isfield(segd,'type') && strcmp(segd.type, 'segm data') &&...
        isfield(segmpar,'type') && strcmp(segmpar.type, 'segmpar')

    % do something
    if d.timederOrder > 0 
        disp('Use location data'); 
        return; 
    end
    for k=1:d.nMarkers
        if segd.parent(k)>0
            i1 = 3*k + (-2:0);
            i2 = 3*segd.parent(k) + (-2:0);
            dist=d.data(:,i1);
            prox=d.data(:,i2);
            cog = prox + (dist-prox)*segmpar.comprox(k)/1000;
            pe(:,k) = 60 * 9.81 * segmpar.m(k)*cog(:,3)/1000;
        end
    end
    
else
    disp('The first input argument should be a variable with MoCap data structure.');
    disp('The second input argument should be a variable with segm data structure.');
    disp('The third input argument should be a variable with segmpar data structure.');
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end