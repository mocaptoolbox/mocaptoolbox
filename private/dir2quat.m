function q = dir2quat(v, base);
%function q = dir2quat(v, base);
%
% converts vector V to the quaternions representing the rotation
% needed to obtain V/norm(V) from BASE (default: BASE = (0,-1,0))
% for an N*3 matrix performs the operation for each row separately
if nargin==1
    base = [0 -1 0];
else
    base = base(:)' / norm(base);
end

q = zeros(size(v,1), 4);

for k=1:size(v,1)
    vv = v(k,:) / norm(v(k,:));
    ax = cross(base, vv); % rotation axis
    ax = ax / norm(ax);
    alpha = acos(dot(base, vv));
    q(k,:) = [cos(alpha/2) ax*sin(alpha/2)];
end

