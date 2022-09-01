function mcc3d2tsv(fn, path)
% Converts a c3d file into a tsv file.
%
% syntax
% mcc3d2tsv(fn, path);
%
% input parameters
% fn: name of c3d file
% path: path to save the tsv file (optional). If no path is given, file is saved to current directory
%
% output
% tsv file, saved in the current or in the specified directory
%
% examples
% mcc3d2tsv('file.c3d')
% mcc3d2tsv('file.c3d', 'folder')
% mcc3d2tsv('file.c3d', '/path/folder') %(Mac)
%
% comments
%
% see also
% mcread
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

if nargin==0
    [file,path] = uigetfile({'*.c3d;', ' .c3d files'}, 'Pick a .c3d file');
    fn = [path file];
end

if exist(fn,'file') == 0 %check if file exists
    disp([10, 'File not found!', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if nargin==1
    path=cd;
end

if fn ~= 0
    [~, name, ~]=fileparts(fn);
    name = strcat(name,'.tsv'); %create tsv file name
    postfix = fn((end-3):end); %get file extension

    if strcmp(postfix, '.c3d')
        d = mcreadc3d(fn);

        if nargin==2 %change to given directory
            currdir = cd; %store current directory
            cd(path);
        end
        if ~strcmp(path(end),'/') %append slash if needed
            path=strcat(path,'/');
        end

        fid = fopen(name, 'w'); %file writing
        fprintf(fid, '%s\t', 'NO_OF_FRAMES');
        fprintf(fid, '%u\n', d.nFrames);
        fprintf(fid, '%s\t', 'NO_OF_CAMERAS');
        fprintf(fid, '%u\n', d.nCameras);
        fprintf(fid, '%s\t', 'NO_OF_MARKERS');
        fprintf(fid, '%u\n', d.nMarkers);
        fprintf(fid, '%s\t', 'FREQUENCY');
        fprintf(fid, '%u\n', d.freq);
        fprintf(fid, '%s\t', 'NO_OF_ANALOG');
        fprintf(fid, '%u\n', 0);%d.nAnalog
        fprintf(fid, '%s\t', 'ANALOG_FREQUENCY');
        fprintf(fid, '%u\n', 0);%d.anaFreq
        fprintf(fid, '%s\t', 'DESCRIPTION');
        fprintf(fid, '%s\n', '--');
        fprintf(fid, '%s\t', 'TIME_STAMP');
        fprintf(fid, '%s\n', '--');
        fprintf(fid, '%s\t', 'DATA_INCLUDED');
        fprintf(fid, '%s\n', '3D');
        fprintf(fid, '%s\t', 'MARKER_NAMES');
        fprintf(fid, '%s\t', d.markerName{:});
        fprintf(fid, '%f\n', []);

        for k=1:size(d.data,1);
            fprintf(fid, '%f\t', d.data(k,:));
            fprintf(fid, '%f\n', []);
        end

        fclose(fid);

        currpwd=strcat(pwd,'/');
        name = strcat(currpwd,name);
        if exist(name,'file') == 2
            disp([10, name, ' written.', 10])
        else
            disp([10, name, ' not written!', 10])
        end
    else
        disp([10, 'This file format is not supported!', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
    end
end

if nargin==2
    cd(currdir);
end
