function d2 = mcfillgaps(d, maxfill, method)
% Fills gaps in motion capture data.
%
% syntax
% d2 = mcfillgaps(d); 
% d2 = mcfillgaps(d, maxfill);
% d2 = mcfillgaps(d, method);
% d2 = mcfillgaps(d, maxfill, method);
%
% input parameters
% d: MoCap, norm, or segm data structure
% maxfill: maximal length of gap to be filled in frames (optional, default = 1000000)
% method: three different options for filling missing frames in the beginning and/or end of a recording:
%   default (parameter empty): missing frames in the beginning and/or in the end are set to 0;
%   'fillall': fills missing frames in the beginning and end of the data with the first actual (recorded)
%       value or the last actual (recorded) value respectively;
%   'nobefill': fills all the gap in the data, but not missing frames in the beginning or 
%       end of the data, but sets them to NaN instead. 
%
% output
% d2: MoCap, norm, or segm data structure
%
% examples
% d2 = mcfillgaps(d);
% d2 = mcfillgaps(d, 120);
% d2 = mcfillgaps(d, 'nobefill');
% d2 = mcfillgaps(d, 60, 'fillall');
%
% comments
% Uses linear interpolation. More sophisticated algorithms will be implemented in the future.
%
% Part of the Motion Capture Toolbox, Copyright 2008,
% University of Jyvaskyla, Finland

d2=[];

if nargin==1
    maxfill=1000000;
    method='';
end

if nargin==2
    if strcmp(maxfill,'fillall') % mcfillgaps(d, 'fillall'); - BB 20100503/20100917
        maxfill=1000000;
        method='fillall';
    elseif strcmp(maxfill,'nobefill') % mcfillgaps(d, 'string'); if no fill of beginning and end - BB 20100917
        maxfill=1000000;
        method='nobefill';
    elseif sum(isletter(maxfill))
        s1='Sorry, do not understand "';
        s2='". Please check your spelling.';
        disp([10, strcat(s1,maxfill,s2), 10]);
        disp([10, 'No gap fill performed.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    else method=''; 
    end
end


if nargin==3 %BB 20100917
    if ~xor(strcmp(method,'fillall')==0, strcmp(method,'nobefill')==0) %BB fix 20111014
        s1='Sorry, do not understand "';
        s2='". Please check your spelling.';
        disp([10, strcat(s1,method,s2), 10]);
        disp([10, 'No gap fill performed.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    d2 = d;
    d2.data = fill(d.data, maxfill, method);
elseif isfield(d,'type') && strcmp(d.type, 'segm data')
    d2 = d;
    d2.roottrans = fill(d.roottrans, maxfill, method);
    d2.rootrot.az = fill(d.rootrot.az, maxfill, method);
    d2.rootrot.el = fill(d.rootrot.el, maxfill, method);
    for k=1:length(d.segm)
        if ~isempty(d.segm(k).eucl) d2.segm(k).eucl = fill(d.segm(k).eucl, maxfill, method); end
        if ~isempty(d.segm(k).angle) d2.segm(k).angle = fill(d.segm(k).angle, maxfill, method); end
        if ~isempty(d.segm(k).quat) d2.segm(k).quat = fill(d.segm(k).quat, maxfill, method); end
    end
else
    disp([10, 'This function works only with MoCap, norm, and segm structures.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end

return

%%%%%%%%%%
function dd2 = fill(dd, maxfill, method)
dd2=zeros(size(dd));

for k=1:size(dd,2)
    nani = isnan(dd(:,k)) | dd(:,k)==0; % logicals for gap frames
    dnani = diff(nani);
    ind1 = find(1-nani);

    gapstart = find(dnani==1);
    gapend = find(dnani==-1);
    if ~isempty(gapstart)
        if isempty(gapend) gapend=length(dd(:,k)); end
        if gapstart(1)>gapend(1) gapstart=[1; gapstart]; end
        if gapstart(end)>gapend(end) gapend=[gapend; length(dd(:,k))]; end
        gaplength = gapend-gapstart;
        notfilled = zeros(length(dd(:,k)),1);
        if ~isempty(gapstart)
            for m=1:length(gapstart)
                if gaplength(m)>maxfill
                    notfilled(gapstart(m):gapend(m)) = 1;
                end
            end
        end

        ind2 = min(ind1):max(ind1); % interpolation range


%         dd2(ind2,k) = interp1(ind1, dd(ind1,k), ind2,'cubic');
        dd2(ind2,k) = interp1(ind1, dd(ind1,k), ind2,'PCHIP'); %recommended by Matlab #BB_20150302
        dd2(find(notfilled),k) = NaN;
    else
        dd2(:,k)=dd(:,k);
    end
    
    if ~isempty(method) %if EITHER 'fillall' OR 'nobefill' is set
        if dd2(1,k)==0 || ~isfinite(dd2(1,k))%check if there is need to fill in the beginning
            if sum(isnan(dd(:,k)))==size(dd,1)%FIXBB110103: if marker is empty
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIX NEEDED HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            elseif isempty(gapend) %THIS GETS CONFUSING HERE! IT SHOULD PROBABLY BE TESTED IN THE UPPER_LEVEL IF-CONDITION - SEEMS THAT SEGM DATA WANTS THAT; BUT DONT GET WHY
            elseif strcmp(method,'fillall')
                ge=gapend(1);%get end (frame no) of first gap
                ged=dd2(ge+1,k);%get data of first recorded frame
                dd2(1:ge,k)=repmat(ged,ge,1);
            elseif strcmp(method,'nobefill')
                ge=gapend(1);%get end (frame no) of first gap
                dd2(1:ge,k)=repmat(NaN,ge,1);
            end
        end
        if dd2(end,k)==0 || ~isfinite(dd2(end,k))
            if sum(isnan(dd(:,k)))==size(dd,1)%FIXBB110103: if marker is empty
            elseif isempty(gapstart) %THIS GETS CONFUSING HERE! IT SHOULD PROBABLY BE TESTED IN THE UPPER_LEVEL IF-CONDITION
            elseif strcmp(method,'fillall')
                gs=gapstart(length(gapstart));%get start (frame no) of last gap
                gsd=dd2(gs-1,k);%get data of start of last gap
                dd2(gs:end,k)=repmat(gsd,length(gs:length(dd2)),1);
            elseif strcmp(method,'nobefill')
                gs=gapstart(length(gapstart));%get start (frame no) of last gap
                dd2(gs:end,k)=repmat(NaN,length(gs:length(dd2)),1);
            end
        end
    end
end
return