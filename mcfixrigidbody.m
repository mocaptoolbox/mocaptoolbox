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
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland
d2=d;

if sum(mcmissing(d))==0 %return if there's nothing to fill
    return
end



% find frames for which all markers are visible, use these for training the
% regression model
trainframes=find(sum(isnan(d.data),2)==0);

for marker=1:d.nMarkers

    % make independent variable
    ivd=mcgetmarker(d,setdiff(1:d.nMarkers,marker));
    iv=ivd.data;

    % make dependent variable
    dvd=mcgetmarker(d,marker);
    dv=dvd.data;

    % train regression model for each of the three dimensions separately
    b=zeros((d.nMarkers-1)*3+1,3);
    for dim=1:3
        b(:,dim)=regress(dv(trainframes,dim),[iv(trainframes,:) ones(length(trainframes),1)]);
    end

    % predict
    pred=[iv ones(size(iv,1),1)]*b;

    % find frames where DV is invisible and all IVs are visible
    predframes=find((sum(isnan(iv),2)==0) & (sum(isnan(dv),2)>0));

    % fill those frames with predicted values
    d2.data(predframes,3*marker+(-2:0))=pred(predframes,:);
end
