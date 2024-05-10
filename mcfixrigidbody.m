function d2 = mcfixrigidbody(d)
% Fills gaps in motion capture data using multiple linear regression.
% Separately for each dimension, frames without missing data are used
% for training a regression model. The models are used to predict missing
% markers in frames with missing data. The function works best if there
% is a large amount of data and little movement.
%
% syntax
% r = mcfixrigidbody(d);
%
% input parameters
% d: MoCap data structure
%
% output
% d2: MoCap data structure
%
% comments
%
% see also
%
% mcfillgaps
%
% Part of the Motion Capture Toolbox, Copyright 2024,
% University of Jyvaskyla, Finland
warning('off', 'stats:regress:RankDefDesignMat')
d2=d;

if sum(mcmissing(d))==0
    return
end
mat = d.data;

lm = 1:width(mat)/3;
lc = 1:width(mat);
for k = lm
    dv = mat(:,ismember(lc,k*3-2:k*3));
    if anynan(dv)
        iv = mat(:,~ismember(lc,k*3-2:k*3));
        nandv = isnan(dv);
        naniv = isnan(iv);
        nantypes = unique([nandv naniv],'rows');
        i = 1;
        clear dv2
        for j = 1:height(nantypes)
            if any(nantypes(j,1:3))
                trainframesl = ~ismember([nandv naniv], nantypes(j,:),'rows');
                keepLogic = ~nantypes(j,4:end);
                iv2 = iv(:,keepLogic);
                [iv3 removeLogic] = rmmissing(iv2,2);
                b = nan(size(iv3,2)+1,3);
                for dim=1:3
                    b(:,dim)=regress(dv(trainframesl,dim),[iv3(trainframesl,:) ones(sum(trainframesl),1)]);
                end
                pred=[iv3 ones(size(iv3,1),1)]*b;
                dv2(:,:,i)=dv;
                dv2(~trainframesl,:,i) = pred(~trainframesl,:);
                i = i+1;
            end
        end
    else
        dv2 = dv;
    end
    s = sort(dv2,3);
    dv3(:,k*3-2:k*3) = s(:,:,1);
end
d2.data = dv3;
warning('on', 'stats:regress:RankDefDesignMat')
