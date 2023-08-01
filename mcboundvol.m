function v = mcboundvol(d,options)
% Calculates the convex hull volume (or its corresponding area on the horizontal plane) that envelops the points of a mocap data structure
%
% syntax
% v = mcboundvol(d,'type'...);
%
% input parameters
% d: MoCap data structure
% 'type': 'volume' or 'area' (default: 'volume')
%
%
% output
% v: vector containing volume in m^3 (or area in m^2) of each frame
%
% examples
%
% v = mcboundvol(d);
%
% a = mcboundvol(d,'type','area');
%
% See also
% mcboundrect
%
% Part of the Motion Capture Toolbox, Copyright 2023,
% University of Jyvaskyla, Finland
    arguments
        d
        options.type = 'volume' % 'volume' or 'area'
    end
    data = d.data;
    for j = 1:size(d.data,1) % each time point
        x = data(j,1:3:end);
        y = data(j,2:3:end);
        z = data(j,3:3:end);
        if strcmpi(options.type,'area')
            dd = [x(:) y(:)];
        elseif strcmpi(options.type,'volume')
            dd = [x(:) y(:) z(:)];
        end
        [~,v(j,:)] = boundary(dd,0);
    end
    if strcmpi(options.type,'area')
        v = v/1000000;
    elseif strcmpi(options.type,'volume')
        v = v/1000000000;
    end
end
