function [d3, p3] = mcmerge(d1, d2, p1, p2)
% Merges two MoCap structures and optionally the corresponding animation parameter files.
%
% syntax
% d3 = mcmerge(d1, d2);
% [d3, p3] = mcmerge(d1, d2, p1, p2);
%
% input parameters
% d1, d2: MoCap or norm data structures
% p1, p2: animpar structures for d1 and d2
%
% output
% d3: MoCap or norm data structure
% p3: animpar structure
%
% comments
% d1 and d2 must have identical frame rates. If the numbers of frames are not equal, the MoCap
% structure with the higher number of frames will be cut before merging.
% All animation parameters will be taken from the first animpar file, apart
% from any color, marker, trace definition, and connection matrices.
%
% see also
% mcconcatenate
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

d3=[]; %BEAUTY FIX BB20110113: if input arguments were not of Mocap or norm data, no system error message thrown anymore (because output argumant not assigned during call)
p3=[];

if nargin<2
    disp([10, 'Not enough input arguments.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

%merging data
if isfield(d1,'type') && strcmp(d1.type, 'MoCap data') && isfield(d2,'type') && strcmp(d2.type, 'MoCap data')
    if d1.freq ~= d2.freq
        disp([10, 'Different frame rates. Cannot merge.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
    if d1.nFrames ~= d2.nFrames
        disp([10, 'Different number of frames in the structures. The longer structure will be cut.', 10])
        N = min(d1.nFrames, d2.nFrames);
        d1.data = d1.data(1:N,:); d2.data = d2.data(1:N,:);
        if isfield(d1, 'other') && isfield(d1,'other')
            if isfield(d1.other,'quat') && isfield(d2.other,'quat')
                d1.other.quat = d1.other.quat(1:N,:); d2.other.quat = d2.other.quat(1:N,:);
            end
        end
        d1.nFrames = N; d2.nFrames = N;
    end
    d3 = d1;
    d3.nMarkers = d1.nMarkers + d2.nMarkers;
    d3.markerName = [d1.markerName; d2.markerName];
    d3.data = [d1.data d2.data];
    if isfield(d1, 'other') && isfield(d1,'other')
        if isfield(d1.other,'quat') && isfield(d2.other,'quat')
            d3.other.quat = [d1.other.quat d2.other.quat];
        end
    end
    %markercolors?
elseif isfield(d1,'type') && strcmp(d1.type, 'norm data') && isfield(d2,'type') && strcmp(d2.type, 'norm data') %FIX BB20110113: norm data also mergeable now
    if d1.freq ~= d2.freq
        disp([10, 'Different frame rates. Cannot merge.', 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return;
    end
    if d1.nFrames ~= d2.nFrames
        disp([10, 'Different number of frames in the structures. The longer structure will be cut.', 10])
        N = min(d1.nFrames, d2.nFrames);
        d1.data = d1.data(1:N,:); d2.data = d2.data(1:N,:);
        d1.nFrames = N; d2.nFrames = N;
    end
    d3 = d1;
    d3.nMarkers = d1.nMarkers + d2.nMarkers;
    d3.markerName = [d1.markerName; d2.markerName];
    d3.data = [d1.data d2.data];
else
    disp([10, 'The first two input arguments should be variables with either MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return %[BBFIX20150720]
end

if nargin>2
    if ~isfield(p1,'type') || ~strcmp(p1.type, 'animpar') || ~isfield(p2,'type') || ~strcmp(p2.type, 'animpar')
        disp([10, 'The last two input arguments should be variables with animpar structure.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end

%merging parameter structures [BBFIX20150720]

if nargin==2 %no animation parameter files given
    p1=mcinitanimpar;
    p2=mcinitanimpar;
elseif nargin==3 %one animation parameter file given
    p2=mcinitanimpar;
end

%two parameter files given or created
p3 = p1;
p3.conn = [p1.conn; d1.nMarkers+p2.conn];
p3.conn2 = [p1.conn2; d1.nMarkers+p2.conn2];
%     p3.trm = [p1.trm; d1.nMarkers+p2.trm];


%color concatenation [BB FIX 20120320]
%color array into 3 digit number
if ischar(p1.colors)
    colors1=NaN(5,3);
    for k=1:5
        colors1(k,:)=lookup_l(p1.colors(k));
    end
end

if ischar(p2.colors)
    colors2=NaN(5,3);
    for k=1:5
        colors2(k,:)=lookup_l(p2.colors(k));
    end
end


%fill markercolors up to have value for all markers
mcol1=NaN(d1.nMarkers,3);
if ischar(p1.markercolors) % but in string format
    for k=1:size(p1.markercolors,2)
        mcol1(k,:)=lookup_l(p1.markercolors(k));%convert to num array
    end
else
    mcol1=p1.markercolors; %field and colors are set in num format already
end
if d1.nMarkers > length(p1.markercolors)
    for k=length(p1.markercolors)+1:d1.nMarkers
        mcol1(k,:)=colors1(2,:);
    end
end
p1.markercolors=mcol1;

if ischar(p2.markercolors) % but in string format
    mcol2=NaN(d2.nMarkers,3);
    for k=1:size(p2.markercolors,2)
        mcol2(k,:)=lookup_l(p2.markercolors(k));%convert to num array
    end
else
    mcol2=p2.markercolors; %field and colors are set in num format already
end
if d2.nMarkers > length(p2.markercolors)
    for k=length(p2.markercolors)+1:d2.nMarkers
        mcol2(k,:)=colors2(2,:);
    end
end
p2.markercolors=mcol2;


%fill conncolors up to have value for all connections
ccol1=NaN(size(p1.conn,1),3);
if ischar(p1.conncolors) % but in string format
    for k=1:size(p1.conncolors,2)
        ccol1(k,:)=lookup_l(p1.conncolors(k));%convert to num array
    end
else
    ccol1=p1.conncolors; %field and colors are set in num format already
end
if size(p1.conn,1) > length(p1.conncolors)
    for k=length(p1.conncolors)+1:size(p1.conn,1)
        ccol1(k,:)=colors1(3,:);
    end
end
p1.conncolors=ccol1;

if ischar(p2.conncolors) % but in string format
    ccol2=NaN(size(p2.conn,1),3);
    for k=1:size(p2.conncolors,2)
        ccol2(k,:)=lookup_l(p2.conncolors(k));%convert to num array
    end
else
    ccol2=p2.conncolors; %field and colors are set in num format already
end
if size(p2.conn,1) > length(p2.conncolors)
    for k=length(p2.conncolors)+1:size(p2.conn,1)
        ccol2(k,:)=colors2(3,:);
    end
end
p2.conncolors=ccol2;


%fill up cwidth
if length(p1.cwidth)<size(p1.conn,1)
    cl1=length(p1.cwidth);
    cwidth1=nan(size(p1.conn,1),1);
    cwidth1(1:length(p1.cwidth))=p1.cwidth;
    for k=cl1+1:length(cwidth1)
        if isnan(cwidth1(k))
            cwidth1(k)=cwidth1(cl1);%fill up with last given value
        end
    end
elseif length(p1.cwidth)>size(p1.conn,1)%if cwidth is longer than conn
    cwidth1=p1.cwidth(1:size(p1.conn,1));
else
    cwidth1=p1.cwidth;
end

if length(p2.cwidth)<size(p2.conn,1)
    cl2=length(p2.cwidth);
    cwidth2=nan(size(p2.conn,1),1);
    cwidth2(1:length(p2.cwidth))=p2.cwidth;
    for k=cl2+1:length(cwidth2)
        if isnan(cwidth2(k))
            cwidth2(k)=cwidth2(cl2);%fill up with last given value
        end
    end
elseif length(p2.cwidth)>size(p2.conn,1)%if cwidth is longer than conn
    cwidth2=p2.cwidth(1:size(p2.conn,1));
else
    cwidth2=p2.cwidth;
end
p3.cwidth = [cwidth1; cwidth2];


%fill tracecolors up to have value for all traces
if p1.trl~=0
    tcol1=repmat(colors1(4,:),d1.nMarkers,1);
    if isfield(p1,'tracecolors') && ~isempty(p1.tracecolors) %(field and) tracecolors are set
        if ischar(p1.tracecolors) % but in string format
            for k=1:size(p1.tracecolors,2)
                tcol1(k,:)=lookup_l(p1.tracecolors(k));%convert to num array
            end
        else
            tcol1(1:size(p1.tracecolors,1),:)=p1.tracecolors; %tracecolors in num format already
        end
    end
    if isempty(p1.trm)
        p1.trm=1:d1.nMarkers; %plot all traces if trm is empty
    else
        if length(p1.trm)<d1.nMarkers
            %sort p1.tracecolors/tcol1 according to p1.trm
            %increase p1.trm to have same length as d1.nMarkers and fill it up with NaNs
            tmp=repmat(colors1(4,:),d1.nMarkers,1);
            tmp1=nan(d1.nMarkers,1)';
            for k=1:length(p1.trm)
                tmp(p1.trm(k),:)=tcol1(k,:);
                tmp1(p1.trm(k))=p1.trm(k);
            end
            tcol1=tmp;
            p1.trm=tmp1;
        end
    end
else %for p1 no traces
    if p2.trl~=0 %but for p2
        tcol1=repmat(colors1(4,:),d1.nMarkers,1);
        p1.trm=nan(d1.nMarkers,1)'; %fill up p1.trm with nan
    else %no traces for p1 and p2
        tcol1=[];
        p1.trm=[];
    end
end
p1.tracecolors=tcol1;

if p2.trl~=0
    tcol2=repmat(colors2(4,:),d2.nMarkers,1);
    if isfield(p2,'tracecolors') && ~isempty(p2.tracecolors) %(field and) tracecolors are set
        if ischar(p2.tracecolors) % but in string format
            for k=1:size(p2.tracecolors,2)
                tcol2(k,:)=lookup_l(p2.tracecolors(k));%convert to num array
            end
        else
            tcol2(1:size(p2.tracecolors,1),:)=p2.tracecolors; %tracecolors in num format already
        end
    end
    if isempty(p2.trm)
        p2.trm=1:d2.nMarkers; %plot all traces if trm is empty
    else
        if length(p2.trm)<d2.nMarkers
            %sort p2.tracecolors/tcol1 according to p2.trm
            %increase p2.trm to have same length as d2.nMarkers and fill it up with NaNs
            tmp=repmat(colors2(4,:),d2.nMarkers,1);
            tmp1=nan(d2.nMarkers,1)';
            for k=1:length(p2.trm)
                tmp(p2.trm(k),:)=tcol2(k,:);
                tmp1(p2.trm(k))=p2.trm(k);
            end
            tcol2=tmp;
            p2.trm=tmp1;
        end
    end
else %for p2 no traces
    if p1.trl~=0 %but for p1
        tcol2=repmat(colors2(4,:),d2.nMarkers,1);
        p2.trm=nan(d2.nMarkers,1)'; %fill up p1.trm with nan
    else %no traces for p1 and p2
        tcol2=[];
        p2.trm=[];
    end
end
p2.tracecolors=tcol2;


%fill up trace widths (twidth) to have same length as traced markers (trm) / nMarkers
%in case less widths are available, it is filled up with last value given in the respective field
if p1.trl~=0
    if length(p1.twidth)<d1.nMarkers
        twidth1=nan(d1.nMarkers,1)';
        i=1;
        for k=1:length(p1.trm)
            if isnan(p1.trm(k))
            else
                twidth1(k)=p1.twidth(i);
                if i<length(p1.twidth)
                    i=i+1;
                end
            end
        end
        p1.twidth=twidth1;
    end
else
    p1.twidth=1;
end

%fill up trace widths (twidth) to have same length as traced markers (trm) / nMarkers
%in case less widths are available, it is filled up with last value given in the respective field
if p2.trl~=0
    if length(p2.twidth)<d2.nMarkers
        twidth2=nan(d2.nMarkers,1)';
        i=1;
        for k=1:length(p2.trm)
            if isnan(p2.trm(k))
            else
                twidth2(k)=p2.twidth(i);
                if i<length(p2.twidth)
                    i=i+1;
                end
            end
        end
        p2.twidth=twidth2;
    end
else
    p2.twidth=1;
end



%fill numbercolors up to have value for all numbers (even in case no numbers are plotted)
if p1.showmnum==1
    ncol1=repmat(colors1(5,:),d1.nMarkers,1);
    if isfield(p1,'numbercolors') && ~isempty(p1.numbercolors) %(field and) numbercolors are set
        if ischar(p1.numbercolors) % but in string format
            for k=1:size(p1.numbercolors,2)
                ncol1(k,:)=lookup_l(p1.numbercolors(k));%convert to num array
            end
        else
            ncol1(1:size(p1.numbercolors,1),:)=p1.numbercolors; %numbercolors in num format already
        end
    end
    if isempty(p1.numbers)
        p1.numbers=1:d1.nMarkers; %plot all markers if numbers is empty
    else
        if length(p1.numbers)<d1.nMarkers
            %sort p1.numbercolors/ncol1 according to p1.numbers
            %increase p1.numbers to have same length as d1.nMarkers and fill it up with NaNs
            tmp=repmat(colors1(5,:),d1.nMarkers,1);
            tmp1=nan(d1.nMarkers,1)';
            for k=1:length(p1.numbers)
                tmp(p1.numbers(k),:)=ncol1(k,:);
                tmp1(p1.numbers(k))=p1.numbers(k);
            end
            ncol1=tmp;
            p1.numbers=tmp1;
        end
    end
else %for p1 no numbers
    if p2.showmnum==1 %but for p2
        ncol1=repmat(colors1(5,:),d1.nMarkers,1);
        p1.numbers=nan(d1.nMarkers,1)'; %fill up p1.numbers with nan
    else
        ncol1=[];
        p1.numbers=[]; %fill up p1.numbers with nan
    end
end
p1.numbercolors=ncol1;

if p2.showmnum==1
    ncol2=repmat(colors2(5,:),d2.nMarkers,1);
    if isfield(p2,'numbercolors') && ~isempty(p2.numbercolors) %(field and) numbercolors are set
        if ischar(p2.numbercolors) % but in string format
            for k=1:size(p2.numbercolors,2)
                ncol2(k,:)=lookup_l(p2.numbercolors(k));%convert to num array
            end
        else
            ncol2(1:size(p2.numbercolors,1),:)=p2.numbercolors; %numbercolors in num format already
        end
    end
    if isempty(p2.numbers)
        p2.numbers=1:d2.nMarkers; %plot all markers if numbers is empty
    else
        if length(p2.numbers)<d2.nMarkers
            %sort p2.numbercolors/ncol1 according to p2.numbers
            %increase p2.numbers to have same length as d2.nMarkers and fill it up with NaNs
            tmp=repmat(colors2(5,:),d2.nMarkers,1);
            tmp1=nan(d2.nMarkers,1)';
            for k=1:length(p2.numbers)
                tmp(p2.numbers(k),:)=ncol2(k,:);
                tmp1(p2.numbers(k))=p2.numbers(k);
            end
            ncol2=tmp;
            p2.numbers=tmp1;
        end
    end
else %for p2 no numbers
    if p1.showmnum==1 %but for p1
        ncol2=repmat(colors2(5,:),d2.nMarkers,1);
        p2.numbers=nan(d2.nMarkers,1)'; %fill up p1.numbers with nan
    else
        ncol2=[];
        p2.numbers=[]; %fill up p1.numbers with nan
    end
end
p2.numbercolors=ncol2;

if ndims(p1.markercolors) == 3 & ndims(p2.markercolors) == 3
    p3.markercolors=cat(3,p1.markercolors,p2.markercolors)
else
    p3.markercolors=[p1.markercolors; p2.markercolors];
end

if ndims(p1.conncolors) == 3 & ndims(p2.conncolors) == 3
    p3.conncolors=cat(3,p1.conncolors,p2.conncolors)
else
    p3.conncolors=[p1.conncolors; p2.conncolors];
end
p3.tracecolors=[p1.tracecolors; p2.tracecolors];
p3.numbercolors = [p1.numbercolors; p2.numbercolors];


p3.trm=[p1.trm, p2.trm];
p3.twidth=[p1.twidth, p2.twidth];

p3.numbers=[p1.numbers, p2.numbers];

if p1.showmnum==1 || p2.showmnum==1 %set p3.showmnum to 1, if p1 or p2 shall plot numbers
    p3.showmnum=1;
end

return;


function colorar=lookup_l(colorstr)
if strcmp(colorstr, 'k')
    colorar=[0 0 0];
elseif strcmp(colorstr, 'w')
    colorar=[1 1 1];
elseif strcmp(colorstr, 'r')
    colorar=[1 0 0];
elseif strcmp(colorstr, 'g')
    colorar=[0 1 0];
elseif strcmp(colorstr, 'b')
    colorar=[0 0 1];
elseif strcmp(colorstr, 'y')
    colorar=[1 1 0];
elseif strcmp(colorstr, 'm')
    colorar=[1 0 1];
elseif strcmp(colorstr, 'c')
    colorar=[0 1 1];
end

return;
