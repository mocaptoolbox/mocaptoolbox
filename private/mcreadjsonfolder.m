function d = mcreadjsonfolder(dr,freq,ReID)
arguments
    dr
    freq = 25;
    ReID = 1 % person re-identification
end
% for openpose 2D (pose only; no support for face and hands yet)
% tested with openpose 1.7; assumes JSON files are in alphanumerical order
% does not ensure person continuity from frame to frame

bp = {'Nose', 'Neck', 'RShoulder', 'RElbow', 'RWrist', 'LShoulder', 'LElbow', 'LWrist', 'MidHip', 'RHip', 'RKnee', 'RAnkle', 'LHip', 'LKnee', 'LAnkle', 'REye', 'LEye', 'REar', 'LEar', 'LBigToe', 'LSmallToe', 'LHeel', 'RBigToe', 'RSmallToe', 'RHeel'};
nbp = numel(bp);
[~,I] = max(arrayfun(@(x) x.bytes,dr)); % find frame with largest number of bytes, assume this has the maximum number of persons
mp = jsondecode(fileread([dr(I).folder filesep dr(I).name]));
[p,n,e] = fileparts(dr(I).name);
if ~strcmpi(e,'.json')
    error('Only .json files are expected in this folder')
end
maxnumpeople = numel(mp.people);
ncomp = numel(mp.people(1).pose_keypoints_2d);
v = nan(1,ncomp*maxnumpeople);
vc = nan(1,ncomp/3*maxnumpeople);
i = 1;
    for k = 1:numel(dr)
        [path, name, ext] = fileparts(dr(k).name);
        if strcmpi(ext,'.json')
            fro = jsondecode(fileread([dr(k).folder filesep dr(k).name]));
            frop = cell2mat(arrayfun(@(x) x.pose_keypoints_2d,fro.people,'un',0))';
            data(i,:) = v;
            conf(i,:) = vc;
            N = size(frop,2);
            data(i,1:N) = zeros(1,N);
            data(i,1:3:N) = frop(1:3:end);
            data(i,3:3:N) = frop(2:3:end);
            conf(i,1:N/3) = frop(3:3:end);
            i = i+1;
        end
    end
bpp = repmat(bp,1,maxnumpeople);
d=mcinitstruct('MoCap data',data,freq,bpp,dr(k).folder);
d.other.conf = conf;


if ReID == 1
    d2 = d;
    d = mcreidentify(d2,nbp);
end

end
