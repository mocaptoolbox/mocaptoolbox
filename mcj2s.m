function d2 = mcj2s(d, par)
% Performs a joint-to-segment mapping.
%
% syntax
% d2 = mcj2s(d, par);
%
% input parameters
% d: MoCap data structure
% par: j2spar structure
%
% output
% d2: segm data structure
% 
% comments
% See explanation of the j2spar structure.
% 
% see also
% mcinitj2spar, mcs2j
%
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland


d2=[];

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if isfield(d,'type') && strcmp(d.type, 'MoCap data') && isfield(par,'type') && strcmp(par.type, 'j2spar')
    d2 = d;
    d2=rmfield(d2,'data');
    d2=rmfield(d2,'markerName');
    d2.type = 'segm data';
    d2.parent = par.parent;
    ind = 3*par.rootMarker + (-2:0);
    d2.roottrans = d.data(:,ind);
    ind1 = 3*par.frontalPlane(1) + (-2:0);
    ind2 = 3*par.frontalPlane(2) + (-2:0);
    ind3 = 3*par.frontalPlane(3) + (-2:0);
    frontalPlane = cross(d.data(:,ind2)-d.data(:,ind1), d.data(:,ind3)-d.data(:,ind1), 2);
    norm = mcnorm(frontalPlane);
    frontalPlaneUnit = frontalPlane ./ repmat(norm,1,3);
    [th,phi,r] = cart2sph(frontalPlaneUnit(:,1),frontalPlaneUnit(:,2),frontalPlaneUnit(:,3));
    th = unwrap(th);
    d2.rootrot.az = 90 + 180*th/pi;
    d2.rootrot.el = 180*phi/pi;
    d = mcrotate(d, -d2.rootrot.az); %%%% added 101208 PT
    % Euclidean parameters
    for k = 1:length(par.parent)
        if par.parent(k)>0
            ind1 = 3*k + (-2:0);
            ind2 = 3*par.parent(k) + (-2:0);
            d2.segm(k).eucl = d.data(:,ind1) - d.data(:,ind2);
            d2.segm(k).r = mcmean(mcnorm(d2.segm(k).eucl));
            % Quaternions
            d2.segm(k).quat = dir2quat(d2.segm(k).eucl);

        end
    end

    % segment angles
    for k = 1:length(par.parent)
        if par.parent(k) > 0 && par.parent(par.parent(k)) > 0
            d2.segm(k).angle = (180/pi)*acos(dot(d2.segm(k).eucl,d2.segm(par.parent(k)).eucl,2)...
                ./(mcnorm(d2.segm(k).eucl).*mcnorm(d2.segm(par.parent(k)).eucl)));
        end
    end
    % Euler angles (2 B added)
    %d2.segm(m).euler =
    d2.segmentName = par.segmentName;
else
    disp([10, 'The first input argument should be a variable with MoCap data structure.']);
    disp(['The second input argument should be a variable with j2spar data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end

