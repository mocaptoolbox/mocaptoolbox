function [d japar] = mcreadtsvTheia(fn);
    ifp = fopen(fn);
    if ifp<0
        disp(['Could not open file ' fn]);
        return;
    end

    d.type = 'MoCap data';
    d.filename = fn;

    s=fscanf(ifp,'%s',1);
    if strcmp('NO_OF_FRAMES', s) == 0
        if strcmp('Objects', s)
            d = mcreadtsvRigid(fn);
            return
        else
            disp('No header information found. Please use the export option Include TSV header in QTM.');
            return
        end
    end
    s=fscanf(ifp,'%s',1); d.nFrames = str2num(s);
    s=fscanf(ifp,'%s',1);
    s=fscanf(ifp,'%s',1); d.nCameras = str2num(s);
    s=fscanf(ifp,'%s',1);
    s=fscanf(ifp,'%s',1); d.freq = str2num(s);
    s=fscanf(ifp,'%s',1); % expects time stamp to be empty
    s=fscanf(ifp,'%s',1);
    s=fscanf(ifp,'%s',1); other.reference = s;
    s=fscanf(ifp,'%s',1);
    s=fscanf(ifp,'%s',1); other.scale = str2num(s);
    s1=fscanf(ifp,'%s',1);
    s1=fscanf(ifp,'%s',1);
    s2=fscanf(ifp,'%s',1); other.solver = [s1 ' ' s2];
    s=fscanf(ifp,'%s',1); % 20080811 fixed bug that prevented reading non-annotated tsv files
    tmp=fgetl(ifp); % 'Frame'
    mn = strsplit(tmp);
    d.markerName = mn(3:8:end)';
    if strcmp(d.markerName{end},'pelvis_shifted')
        d.markerName(end) = []; % remove for the time being
        flag_pelvis_shifted = 1;
    end
    d.nMarkers = numel(d.markerName);
    allData = nan(d.nFrames,length(mn));
    i = 1;
    for k = 1:size(allData,1)
        dataRow = str2num(fgetl(ifp));
        if ~isempty(dataRow)
            allData(i,:)=dataRow;
            i = i+1;
        end
    end
    fclose(ifp);
    d.data = allData(:,matches(mn,lettersPattern(1)));
    if flag_pelvis_shifted == 1;
        d.data(:,end-2:end) = [];
    end
    d.analogdata = [];
    other.quat = allData(:,matches(mn,lettersPattern(2)));
    if flag_pelvis_shifted == 1;
        other.quat(:,end-3:end) = [];
    end
    d.other = other;
    clI = find(matches(d.markerName,{'l_clavicle','r_clavicle'}));
    d = mcrmmarker(d,clI);% remove l_clavicle and r_clavicle because they only add two rotational degrees of freedom (about anterior-posterior and superior-inferior axes). Their position is identical to that of torso.
    load('mcdemodata.mat','m2jpar');
    m2jpar.nMarkers = 17;
    m2jpar.markerName([10,16,20]) = []; % remove midtorso and fingers
    m2jpar.markerNum = [{[2 6]} {[2]} {[3]} {[4]} {[5]} {[6]} {[7]} {[8]} {[9]} {[11 14]} {[17]} {[11]} {[12]} {[13]} {[14]} {[15]} {[16]}]; % neck and root are based on shoulders and hips, respectively
    d = mcm2j(d,m2jpar);
    d.markerName = d.markerName(:);
    load('mcdemodata.mat','japar');
    japar.conn = japar.conn(1:10,:);
    japar.conn = [japar.conn; 10 12; 12 13; 13 14; 10 15; 15 16; 16 17];
    % reorder the quaternions
    m2jpar.markerNum = [{[1]} {[2]} {[3]} {[4]} {[5]} {[6]} {[7]} {[8]} {[9]} {[10]} {[17]} {[11]} {[12]} {[13]} {[14]} {[15]} {[16]}];
    qOrder = cell2mat(arrayfun(@(x) (1:4)+(x*4-4), cell2mat(m2jpar.markerNum),'un',0));
    other.quat = other.quat(:,qOrder);
end
