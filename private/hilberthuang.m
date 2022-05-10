function [h0, h1, up, down] = hilberthuang(d, N);
% function [h0, h1, up, down] = hilberthuang(d, N);

if nargin==1 N=1;end

h0 = zeros(size(d)); h1=h0;
for n=1:N
    for k=1:size(d,2)
        dd=d(:,k);

        minl = [1; 1+find(diff(sign(diff(dd)))==2); length(dd)];
        maxl = [1; 1+find(diff(sign(diff(dd)))==-2); length(dd)];
        minv = dd(minl);
        maxv = dd(maxl);

        up = interp1(maxl,maxv,1:length(dd),'spline')';
        up(1:maxl(1))=dd(1:maxl(1)); up(maxl(end):end)=dd(maxl(end):end);
        up = max(up,dd);
        down = interp1(minl,minv,1:length(dd),'spline')';
        down(1:minl(1))=down(1:minl(1)); down(minl(end):end)=dd(minl(end):end);
        down=min(down,dd);

        h0(:,k) = (up+down)/2;
        h1(:,k) = dd-h0(:,k);
    end
    d=h1;
end
