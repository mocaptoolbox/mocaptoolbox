function w = quatrot(v, q)
% function w = quatrot(v, q)
%
% Rotates vector V by quaternion Q.
%
% The function uses quaternions that are defined using the scalar-first convention (q must have its scalar number as the first column).
% If quaternions are not yet normalized, the function normalizes them.
% The applied rotation uses the right-hand rule.
% The function also accepts an N by 3 matrix V and an N by 4 matrix Q as input arguments.

if unique(sqrt(sum(q.^2,2))) ~= 1
    quat_normalize = @(Q) Q./sqrt(sum(Q.^2,2));
    q = quat_normalize(q);
end

w = zeros(size(v));


    t2 = q(:,1).*q(:,2);
    t3 = q(:,1).*q(:,3);
    t4 = q(:,1).*q(:,4);
    t5 = -q(:,2).*q(:,2);
    t6 = q(:,2).*q(:,3);
    t7 = q(:,2).*q(:,4);
    t8 = -q(:,3).*q(:,3);
    t9 = q(:,3).*q(:,4);
    t10 = -q(:,4).*q(:,4);
    w(:,1) = 2*((t8 + t10).*v(:,1) + (t6 - t4).*v(:,2) + (t3 + t7).*v(:,3)) + v(:,1);
    w(:,2) = 2*((t4 + t6).*v(:,1) + (t5 + t10).*v(:,2) + (t9 - t2).*v(:,3)) + v(:,2);
    w(:,3) = 2*((t7 - t3).*v(:,1) + (t2 +  t9).*v(:,2) + (t5 + t8).*v(:,3)) + v(:,3);
