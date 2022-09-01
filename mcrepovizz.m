function mcrepovizz(d, path, p)
% Exports MoCap structure as valid repoVizz .csv files, .xml repoVizz struct and optional .bones file.
%
% syntax
% mcrepovizz(d, path, p);
%
% input parameters
% d: MoCap data structure
% path: path to save the .csv files (optional). If no path is given, files
% are saved in the current directory. If the chosen directory does not
% exist, it will be created.
% p: animpar parameter structure (optional)
%
% output
% .csv files and repoVizz struct .xml file saved in the current or in the specified directory.
% Optional .bones file saved as well if animpar structure specified in the third argument
%
% examples
% mcrepovizz(d)
% mcrepovizz(d, 'folder')
% mcrepovizz(d, '/path/folder') %(only Mac)
% mcrepovizz(d, 'folder', p)
% mcrepovizz(d, p)
%
% comments
% For info about repoVizz: http://repovizz.upf.edu/
%
% see also
% mcread, mcwritetsv
%
% Script developed by Federico Visi @ Interdisciplinary Centre for Computer Music Research (ICCMR), Plymouth University.
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland


a=[];

% Checks if first input is a MoCap data structure
if isfield(d, 'type') && strcmp(d.type, 'MoCap data')
else
    disp([10, 'Input is not a MoCap data structure. No files written.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

% Checks if second input animpar struct
if nargin>=2
    if isfield(path, 'type') && strcmp(path.type, 'animpar')
    a=path;
    path=cd;
    elseif isempty(path) || isnumeric(path)
        path=cd;
        disp([10, 'Given path is ambiguous. Files are written to the current folder.' 10])
    end
end

% Checks if third argument is an animpar parameter structure (if not given, all files apart from the bones file will be written)
if nargin==3
    if isfield(p, 'type') && strcmp(p.type, 'animpar')
        a=p;
    else disp([10, 'The third argument must be an animpar parameter structure. No .bones file written.' 10])
    end
end



% Path
if nargin==1
    path=cd;
end

if ~exist(path,'dir')
    mkdir(path);
end

if ~strcmp(path(end),'/')
    path=strcat(path,'/');
end


% create .bones FILE if animpar struct is given%
if isstruct(a)
    % Creates file name.
    [~, name, ~]=fileparts(d.filename);
    filename=strcat(name,'.bones');
    filename=strcat(path,filename);

    % Creates repoVizz .bones file
    bonesFile = fopen(filename,'w');

    % Bones from a.conn
    for ii = 1:size(a.conn,1)
        m1 = char(d.markerName(a.conn(ii,1)));
        m2 = char(d.markerName(a.conn(ii,2)));
        fprintf(bonesFile,'B, %s.%s, %s.%s\n',m1,name,m2,name);
    end
end


n = size(d.data); n = n(1,2);

minval=min(min(d.data));
maxval=max(max(d.data));


% X AXIS %
jj=0;

for ii = 1:3:n

    jj=jj+1;

    % Creates file name.
    filename=char(d.markerName(jj));
    filename=strcat(filename,'_X');
    filename=strcat(filename,'.csv');
    filename=strcat(path,filename);

    % Creates axis data vector and obtains info for csv header
    a = (d.data(:,ii))';
    framerate = d.freq;

    % Creates repoVizz csv files for X axis
    fileID = fopen(filename,'w');
    fprintf(fileID,'repovizz,framerate=%.2f,minval=%f,maxval=%f\n',framerate,minval,maxval);
    fprintf(fileID,'%f,',a);
    fclose(fileID);

end

% Y AXIS %
jj=0;

for ii = 2:3:n

    jj=jj+1;

    % Creates file name.
    filename=char(d.markerName(jj));
    filename=strcat(filename,'_Y');
    filename=strcat(filename,'.csv');
    filename=strcat(path,filename);

    % Creates axis data vector and obtains info for csv header
    a = (d.data(:,ii))';
    framerate = d.freq;

    % Creates repoVizz csv files for Y axis
    fileID = fopen(filename,'w');
    fprintf(fileID,'repovizz,framerate=%.2f,minval=%f,maxval=%f\n',framerate,minval,maxval);
    fprintf(fileID,'%f,',a);
    fclose(fileID);

end

% Z AXIS %
jj=0;

for ii = 3:3:n

    jj=jj+1;

    % Creates file name.
    filename=char(d.markerName(jj));
    filename=strcat(filename,'_Z');
    filename=strcat(filename,'.csv');
    filename=strcat(path,filename);

    % Creates axis data vector and obtains info for csv header
    a = (d.data(:,ii))';
    framerate = d.freq;

    % Creates repoVizz csv files for Z axis
    fileID = fopen(filename,'w');
    fprintf(fileID,'repovizz,framerate=%.2f,minval=%f,maxval=%f\n',framerate,minval,maxval);
    fprintf(fileID,'%f,',a);
    fclose(fileID);
end


% XML FILE %
% Creates file name.
[~, name, ~]=fileparts(d.filename);
filename=strcat(name,'.xml');
filename=strcat(path,filename);

% Creates repoVizz XML data struct
fileID = fopen(filename,'w');

fprintf(fileID,'<ROOT ID="ROOT0">\n');

% MoCap Group Node
fprintf(fileID,'<Generic ID="ROOT0_MoCa0" Category="MoCapGroup" Name="%s" _Extra="" Expanded="1">\n',name);

% Bones node
if nargin==3
    fprintf(fileID,'<File ID="ROOT0_MoCa0_MoCa0" Expanded="1" Category="MoCapLinks" Name="%s" FileType="bones" DefaultPath="0" Filename="%s.bones" _Extra="canvas=-1,color=0,selected=1" />\n',name,name);
end

for ii = 1:d.nMarkers
    markerName = char(d.markerName(ii));
    fprintf(fileID,'<Generic Name="%s.%s" _Extra="" ID="ROOT0_MoCa0_MoCa1" Category="MoCapMarker" Expanded="1">\n',markerName,name);
    fprintf(fileID,'<Signal ID="ROOT0_MoCa0_MoCa1_X0" Expanded="0" Category="X" Name="X" FileType="CSV" DefaultPath="0" Filename="%s_X.csv" BytesPerSample="" FrameSize="" MaxVal="%.3f" MinVal="%.3f" NumChannels="" NumSamples="" SpecSampleRate="0.0" EstimatedSampleRate="0.0" ResampledFlag="-1" _Extra="canvas=-1,color=0,selected=1" SampleRate="%.2f" />\n',markerName,maxval,minval,d.freq);
    fprintf(fileID,'<Signal ID="ROOT0_MoCa0_MoCa1_Y0" Expanded="0" Category="Y" Name="Y" FileType="CSV" DefaultPath="0" Filename="%s_Y.csv" BytesPerSample="" FrameSize="" MaxVal="%.3f" MinVal="%.3f" NumChannels="" NumSamples="" SpecSampleRate="0.0" EstimatedSampleRate="0.0" ResampledFlag="-1" _Extra="canvas=-1,color=0,selected=1" SampleRate="%.2f" />\n',markerName,maxval,minval,d.freq);
    fprintf(fileID,'<Signal ID="ROOT0_MoCa0_MoCa1_Z0" Expanded="0" Category="Z" Name="Z" FileType="CSV" DefaultPath="0" Filename="%s_Z.csv" BytesPerSample="" FrameSize="" MaxVal="%.3f" MinVal="%.3f" NumChannels="" NumSamples="" SpecSampleRate="0.0" EstimatedSampleRate="0.0" ResampledFlag="-1" _Extra="canvas=-1,color=0,selected=1" SampleRate="%.2f" />\n',markerName,maxval,minval,d.freq);
    fprintf(fileID,'</Generic>\n');
end

fprintf(fileID,'</Generic>\n');

fprintf(fileID,'</ROOT>');
fclose(fileID);

end
