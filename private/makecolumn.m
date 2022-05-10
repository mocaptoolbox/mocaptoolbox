function r = makecolumn(s)

%   MAKECOLUMN forces row vector to be a column vector

sz = size(s);

if sz(1) < sz(2)
    if length(sz) == 2
        r = s';
    elseif length(sz) == 3
        r = permute(s,[2 1 3]);
    end
else
    r = s;
end
