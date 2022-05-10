function d2 = mcrotate(d, theta, axis, point)
% Rotates motion-capture data.
%
% syntax
% d2 = mcrotate(d, theta);
% d2 = mcrotate(d, theta, axis);
% d2 = mcrotate(d, theta, point);
% d2 = mcrotate(d, theta, axis, point);
%
% input parameters
% d: MoCap structure or data matrix
% theta: rotation angle (in degrees)
% axis: rotation axis (optional, default = [0 0 1])
% point: point through which the rotation axis goes (optional, default is the centroid of markers over time)
%
% output
% d2: MoCap structure or data matrix
%
% examples
% d2 = mcrotate(d, 130); % rotate 130 degrees counterclockwise around the vertical axis
% d2 = mcrotate(d, 90, [1 0 0]); % rotate around the x axis
% d2 = mcrotate(d, 45, [0 1 0], [0 0 500]); % rotate around the axis parallel to y axis going through point [0 0 500]
% d2 = mcrotate(d, 20, [], [0 1000 0]); % rotate around the z (vertical) axis going through point [0 1000 0]
%
% comments
% If theta is a vector, its values are used as evenly-spaced break points in interpolation. 
% This allows the creation of dynamic rotation of the data.
% Rotation is performed according to the right-hand rule. For instance, if the rotation axis 
% is pointing vertically upwards, positive rotation angle means counterclockwise rotation 
% when viewed from up.
%
% see also
% mc2frontal
% 
% Part of the Motion Capture Toolbox, Copyright  2008,
% University of Jyvaskyla, Finland

d2=[];

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    dat = d.data;
elseif isnumeric(d)
    dat = d;
else 
    disp([10, 'The first input argument has to be a variable with MoCap data structure or a numeric array.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

if ~isnumeric(theta)
    disp([10, 'The second input argument has to be numeric.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin==3 && (~isnumeric(axis) || length(axis)~=3)
    disp([10, 'The third input argument has to be a numeric array with the length of 3.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin==4 && (~isnumeric(point) || length(point)~=3)
    disp([10, 'The fourth input argument has to be numeric.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

%%%%%%%%%%%%%%%%

N = size(dat,1);
if length(theta)==1 
    theta = theta*ones(N,1);
else
    theta = interp1(linspace(1,N,length(theta)),theta,1:N)';
end
if nargin<3 || isempty(axis) 
    axis = [0 0 1]; 
end

x = dat(:,1:3:end); y = dat(:,2:3:end); z = dat(:,3:3:end);

if nargin<4
    xx=x(:);xxx=xx(isfinite(xx)); yy=y(:);yyy=yy(isfinite(yy)); zz=z(:);zzz=zz(isfinite(zz));
    point = [mean(xxx) mean(yyy) mean(zzz)];
end

mx = point(1); my = point(2); mz = point(3);

dat2 = [];
for k=1:size(x,2) % per marker
    ind=find(isfinite(x(:,k)));
    if ~isempty(ind) %% added 250511 PT
        q = [cos(pi*theta(ind)/360) axis(1)*sin(pi*theta(ind)/360) axis(2)*sin(pi*theta(ind)/360) axis(3)*sin(pi*theta(ind)/360)];
        w = quatrot([x(ind,k)-mx,y(ind,k)-my,z(ind,k)-mz], q);
        x(ind,k) = w(:,1);
        y(ind,k) = w(:,2);
        z(ind,k) = w(:,3);
    end
    
    dat2 = [dat2 x(:,k)+mx y(:,k)+my z(:,k)+mz];
end

%%%%%%%%%%%%%%%%

if isfield(d,'type') && strcmp(d.type, 'MoCap data')
    d2 = d;
    d2.data = dat2;
else
    d2 = dat2;
end

