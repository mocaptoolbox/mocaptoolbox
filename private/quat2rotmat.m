function R = quat2rotmat( q )
% function R = RotationMatrix( q )  or  R = q.RotationMatrix
% Construct rotation (or direction cosine) matrices from quaternions
% Input:
%  q        quaternion array
% Output:
%  R        3x3xN rotation (or direction cosine) matrices
%
% Author:
%  Mark Tincknell, MIT LL, 29 July 2011, revised 25 July 2017
    siz = size(q,1);
    R   = zeros( [3 3 siz] );
    nel = prod( siz );
    quat_normalize = @(Q) Q./sqrt(sum(Q.^2,2));
    q = quat_normalize(q);
    for iel = 1 : nel
        e12 = q(:,1) * q(:,2);
        e13 = q(:,1) * q(:,3);
        e14 = q(:,1) * q(:,4);
        e22 = q(:,2)^2;
        e23 = q(:,2) * q(:,3);
        e24 = q(:,2) * q(:,4);
        e33 = q(:,3)^2;
        e34 = q(:,3) * q(:,4);
        e44 = q(:,4)^2;
        R(:,:,iel)  = ...
            [ 1 - 2*( e33 + e44 ), 2*( e23 - e14 ), 2*( e24 + e13 ); ...
              2*( e23 + e14 ), 1 - 2*( e22 + e44 ), 2*( e34 - e12 ); ...
              2*( e24 - e13 ), 2*( e34 + e12 ), 1 - 2*( e22 + e33 ) ];
        %            [ e11 + e22 - e33 - e44, 2*(e23 - e14), 2*(e24 + e13); ...
        %              2*(e23 + e14), e11 - e22 + e33 - e44, 2*(e34 - e12); ...
        %              2*(e24 - e13), 2*(e34 + e12), e11 - e22 - e33 + e44 ];
    end
    R   = chop( R );
end % RotationMatrix
function out = chop( in, tol )
% function out = chop( in, tol )
% Replace values that differ from an integer by <= tol by the integer
% Inputs:
%  in       input array
%  tol      tolerance, default = eps(16)
% Output:
%  out      input array with integer replacements, if any
if (nargin < 2) || isempty( tol )
    tol = eps(16);
end
out = double( in );
rin = round( in );
lx  = abs( rin - in ) <= tol;
out(lx) = rin(lx);
end % chop
