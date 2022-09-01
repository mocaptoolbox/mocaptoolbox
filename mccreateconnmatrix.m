function p = mccreateconnmatrix(fn, p)
% Creates a connection matrix for the animation parameters (.conn field) by
% using the "bones" connections saved as a label list of the Qualisys track
% manager software (QTM).
%
% syntax
% par = mccreateconnmatrix(fn, p);
%
% input parameters
% fn: text file (ending: .txt) that contains the "bones" (connections) made in QTM
% p: animpar structure
%
% output
% par: animpar structure with connection matrix
%
% examples
% par = mccreateconnmatrix('labellist.txt', par);
%
% comments
% This function works only with label list files created by Qualisys Track Manager.
% This function works for marker representations (before any marker reduction
% or joint transformation has been applied). The markers in the MoCap structure
% must resemble the structure of the marker connections in the label list file.
%
% see also
% mcinitanimpar
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland



if nargin==1
    p = mcinitanimpar;
end

if ~ischar(fn)
    disp([10, 'The first input argument is not a file.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return;
end

ifp = fopen(fn);
if ifp<0
    disp([10, 'Could not open file ' fn, 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    p=[];
    return;
end

%MAYBE TODOs: chatch if people only give a animpar struct and no labellist
%and then open the file open dialog, or to call the function without any
%parameter and open the file open dialog and take initanimparam - big
%check of the input parameters

if fn ~= 0
    postfix = fn((end-3):end);
    if ~strcmp(postfix,'.txt')
        disp([10, 'This file format is not supported.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        p=[];
        return;
    end
end

tl = fgetl(ifp);
n=1;

while ischar(tl)
    if strfind(tl, '<Bone>') > 0 %find the bone connections
        tl = fgetl(ifp); %the needed info is the next line
        tmp = textscan(tl,'%s%d%s%d%s','delimiter','"'); %convert line to cell array
        cv=[tmp{2}, tmp{4}]; %get the two marker numbers
        p.conn(n,:) = cv; %store them in the connection matrix
        n=n+1;
    end
    tl = fgetl(ifp);
end

fclose(ifp);
