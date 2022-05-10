function mcdemo10
% This example shows how to use Principal components analysis to decompose 
% Motion Capture data into components that are orthogonal to each other.
%
% Let us extract the first four seconds from the structure dance2

load mcdemodata
d=mctrim(dance2,0,4);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% and convert it into a joint representation

j=mcm2j(d, m2jpar);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Next, we calculate the first three principal component projections of the
% structure j

[pc,p]=mcpcaproj(j,1:3);

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% and plot the amount of variance contained in these principal components
bar(p.l(1:3))

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% We see that the first PC contains ca. 85% of the variance, while the 
% next two components contain only 9% and 2%.
% 
% The PC projections can be investigated, for instance, by creating 
% animations:
%
% Please choose the directory where you want the animtaion frames to be 
% stored:

path = uigetdir([], 'Choose a Directory')

olddir = cd; 
cd(path)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

mcanimate(pc(1), japar);

cd(olddir)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% The animations show that the principal component distort the body segment 
% relations, in particular, the lengths of certain body segments vary. 
% Often better results can be obtained by performing the PCA on the 
% segment representation
s=mcj2s(j,j2spar); % convert to segment structure
[pcs,ps]=mcpcaproj(s,1:3); % perform PCA
for k=1:3 % convert PC projections back to joint structures
    pcj(k) = mcs2j(pcs(k), j2spar);
end

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Next, let us plot the first three PC projections
plot(ps.c(1:3,:)'), legend('PC1','PC2','PC3')

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% The plot reveals that the first PC correspond to non-periodic motion, 
% while PCs 2 and 3 correspond to (almost) periodic motion. Animation of 
% pcj(k) shows that the first three PCs correspond to translation of the 
% body, periodic anti-phase movement of arms, and periodic rotation of 
% torso.

