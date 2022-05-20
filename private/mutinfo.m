function z = mutinfo(x, y, binsizetype, binvalue)
% function z = mutinfo(x, y, binsizetype, binvalue)
% Compute mutual information I(x,y) of two discrete variables x and y.
%
% INPUT:
% x: T x N1 matrix of signals
% y: T x N2 matrix of signals
% binsizetype (optional, if not given, uses the Freedman-Diaconis rule):
%   'number': sets number of bins for marginal distributions
%   'size': sets size of bins for marginal distributions
% binvalue: value associated with binsizetype
%
% OUTPUT
% z: N1 x N2 matrix of mutual information values
%
% examples:
% z = mutinfo(x,y);
% z = mutinfo(x,y,'number',30);
% z = mutinfo(x,y,'size',0.1);

if nargin==2
    binsizetype='auto';
elseif strcmp(binsizetype,'number')
    nbins=binvalue;
elseif strcmp(binsizetype,'size')
    binsize=binvalue;
end

if size(x,1)>size(x,2) x=x'; end
if size(y,1)>size(y,2) y=y'; end
n=size(x,2);
idx = 1:n;


for xind=1:size(x,1)
    for yind=1:size(y,1)
        xx=x(xind,:);
        yy=y(yind,:);
        if strcmp(binsizetype,'auto')        % Freedman-Diaconis rule
            xbinsize=2*iqr(xx)*(length(xx).^(-1/3));
            ybinsize=2*iqr(yy)*(length(yy).^(-1/3));
            xbins=ceil((max(xx)-min(xx))/xbinsize);
            ybins=ceil((max(yy)-min(yy))/ybinsize);
        elseif strcmp(binsizetype,'number')
            xbins=nbins;
            ybins=nbins;
        elseif strcmp(binsizetype,'size')
            xbinsize=binsize;
            ybinsize=binsize;
            xbins=ceil((max(xx)-min(xx))/xbinsize);
            ybins=ceil((max(yy)-min(yy))/ybinsize);
        end

        xx = xx-min(xx);
        yy = yy-min(yy);

        xx=(xbins-1)*xx/max(xx)+1;
        yy=(ybins-1)*yy/max(yy)+1;

        Mx = sparse(idx,round(xx),1,n,ceil(xbins),n);
        My = sparse(idx,round(yy),1,n,ceil(ybins),n);
        Pxy = nonzeros(Mx'*My/n); %joint distribution of x and y
        Hxy = -dot(Pxy,log(Pxy+eps));

        Px = mean(Mx,1);
        Py = mean(My,1);

        % entropy of Py and Px
        Hx = -dot(Px,log2(Px+eps));
        Hy = -dot(Py,log2(Py+eps));

        % mutual information
        z(xind,yind) = Hx + Hy - Hxy;
    end
end
