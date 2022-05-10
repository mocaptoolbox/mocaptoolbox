 function mcwritetsv(d, path, fn)
% Saves mocap structure as tsv file.
%
% syntax
% mcwritetsv(d, path, fn)
%
% input parameters
% d: MoCap data structure
% path: path to save the tsv file (optional). If no path is given, file is saved to current directory
% fn: set file name for tsv file (optional). If nothing is given, the name of the original recirding is used
%
% output
% tsv file, saved in the current or in the specified directory
%
% examples
% mcwritetsv(d)
% mcwritetsv(d, 'folder')
% mcwritetsv(d, '/path/folder') %(Mac)
% mcwritetsv(d, '/path/folder','rec1')
%
% comments
% Thanks to Roberto Rovegno, University of Genoa, Italy, for contributing to this code
%
% see also
% mcread
% 
% Part of the Motion Capture Toolbox, Copyright ?2008,
% University of Jyvaskyla, Finland

if ~isfield(d,'type') || ~strcmp(d.type, 'MoCap data')
    disp([10, 'The first input argument has to be a variable with MoCap data structure.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end
if nargin>=2 
    if ~ischar(path)
        disp([10, 'The second input argument has to be a string.' 10])
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
end
if nargin==3 && ~ischar(fn)
    disp([10, 'The third input argument has to be a string.' 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end
    
%create file name
[~, name, ~]=fileparts(d.filename);

if nargin==3 %add BB20141118 to have the option of splitting recordings into seperate files
    name=fn;
end 

name=strcat(name,'.tsv');

if nargin==1
    path=cd;
end

if ~strcmp(path(end),'/')
    path=strcat(path,'/');
end

name = strcat(path,name);

[fid, ems] = fopen(name, 'w');

if ~isempty(ems)
    disp([10, 'Path unknown.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end
    
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

fprintf(fid, '%s\n', 'DESCRIPTION--');
% if strcmp('DESCRIPTION', d.other.descr(1:11))
%     fprintf(fid, '%s\n', d.other.descr(12:end));
% else
%     fprintf(fid, '%s\n', d.other.descr);
% end

fprintf(fid, '%s\n', 'TIME_STAMP--');
% if strcmp('TIME_STAMP', d.other.timeStamp(1:10))
%     fprintf(fid, '%s\n', d.other.timeStamp(12:end));
% else
%     fprintf(fid, '%s\n', d.other.timeStamp);
% end

fprintf(fid, '%s\t', 'DATA_INCLUDED');
fprintf(fid, '%s\n', '3D');%BB20141120 make this fixed to 3d, as...
% fprintf(fid, '%s\n', d.other.dataIncluded); %... this crashed with the MARCS Vicon c3d files read in
fprintf(fid, '%s\t', 'MARKER_NAMES');
fprintf(fid, '%s\t', d.markerName{:});
fprintf(fid, '%f\n', []);

for k=1:size(d.data,1);
    fprintf(fid, '%f\t', d.data(k,:));
    fprintf(fid, '%f\n', []);
end

fclose(fid);

if exist(name,'file') == 2
    disp([10, name, ' written.', 10])
else
    disp([10, name, ' not written!', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
   
