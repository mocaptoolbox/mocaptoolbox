function r = mcreidentify(d,nbp,distance)
arguments
    d % 3D mocap data
    nbp % number of body parts per person (assumes equal number per person)
    distance = 'euclidean' % distance used to reidentify each person at each frame based on previous frame
end
    d2 = d;
    for k = 1:height(d2.data)-1
        a = d2.data(k,:)';
        b = d2.data(k+1,:)';
        ra = reshape(a,nbp*3,[]);
        rb = reshape(b,nbp*3,[]);
        [~,I] = pdist2(ra',rb',distance,'Smallest',width(ra));
        ind = I(1,:);
        if ~(numel(unique(I(1,:))) == numel(I(1,:)))
            for j = 2:width(I)
                i = 2;
                while ismember(ind(j),ind(1:j-1))
                    ind(j) = I(i,j);
                    i = i+1;
                end
            end
        end
        indf = [];
        indfm = [];
        for kk = 1:numel(ind)
            indfm(kk,1:nbp*3) = (1:nbp*3)+((ind(kk)-1)*nbp*3); % Unable to perform assignment because the size of the left side is 1-by-75 and the size of the right side is 1-by-78.
        end
        indf = reshape(indfm',[],1);
        d2.data(k+1,:) = d2.data(k+1,indf);
        if isfield(d2.other,'conf')
            indfc = [];
            indfmc = [];
            for kk = 1:numel(ind)
                indfmc(kk,1:nbp) = (1:nbp)+((ind(kk)-1)*nbp); % Unable to perform assignment because the size of the left side is 1-by-75 and the size of the right side is 1-by-78.
            end
            indfc = reshape(indfmc',[],1);
            d2.other.conf(k+1,:) = d2.other.conf(k+1,indfc);
        end
    end
r = d2;
end
