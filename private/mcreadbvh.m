function d = mcreadbvh(fn);
% Read bvh format
% Created by De Beul Dominique  2014/03/31-2014/03/31
% Departement of Computer Science
% UMONS University, Faculté Polytechnique de Mons (FPMS), Mons, Belgium
% used by permission
%
% Convert bvh structure to MoCap Toolbox structure
% Need the Lawrence's toolbox
% (http://staffwww.dcs.shef.ac.uk/people/N.Lawrence/mocap/) - Tested with v0.136

% read the data 
[skel, channels, frameLength] = bvhReadFile(fn);

% create MoCap structure
d.type = 'MoCap data';        
d.filename = skel.name;
d.nFrames = size(channels,1);
d.nCameras = 0;
d.nMarkers = size(skel.tree,2);
d.freq = frameLength;
d.nAnalog = [];
d.anaFreq= [];
d.timederOrder = 0;
d.markerName = [];
d.data = [];
d.analogdata = [];
d.other = [];

% organize data
for i=1:size(skel.tree,2)
     d.markerName{i,1} = skel.tree(i).name;    
end

for i = 1:size(channels,1)
    vals=skel2xyz(skel, channels(i,:));
    tmp=vals(1,:);
    for j = 2:size(skel.tree,2)    
        tmp=[tmp vals(j,:)];
    end
    d.data(i,:)=tmp;
end

disp(strcat(fn,' loaded'))