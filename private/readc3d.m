function data =readc3d(fname,header)
% This function will read a .C3D file and output the data in a structured
% array
% data = readc3d(fname)
% fname = the c3d file and path (as a string) eg: 'c:\documents\myfile.c3d'
% data is a structured array
% 
% see also writec3d.m
%
% CAUTION: machinetype variable may not be correct for intel or MIPS C3D files.
% This m-file needs to be tested with C3D files of these types.
% This m-file was tested and passed with DEC (VAX PDP-11) C3D files
%
% CAUTION: only character, integer, and real numbers have been tested.
% see http://www.c3d.org/HTML/default.htm for information
%
% CAUTION: residuals of 3D data are not handled
%
%
%Created by JJ Loh  2006/09/10
%Departement of Kinesiology
%McGill University, Montreal, Quebec Canada
%
%updated by JJ loh 2008/03/08
%video channels can handle NaN's
%
%updated by JJ Loh 2008/04/10
%header can be outputed alone
% -------------------------------------------

mtype = getmachinecode(fname);
switch mtype
    case 84  %intel
        machinetype = 'ieee-le';
    case 85 %DEC (VAX PDP-11)
        machinetype = 'ieee-le';%'vaxd'; %Try vaxd if you run into issues when reading in files
    case 86 %MIPS
        machinetype = 'ieee-be';
end
fid=fopen(fname,'r',machinetype);           % if "DEC" selected in export c3d options in IQ you will get an error, change to PC

%--------------------HEADER SECTION----------------------------------------
%  Reading record number of parameter section
pblock=fread(fid,1,'int8');         %getting the 512 block number where the paramter section is located block 1 = first 512 block of the file
fread(fid,1,'int8');           %code for a C3D file

%  Getting all the necessary parameters from the header record
%                                  word     description
H.ParamterBlockNum = pblock;
H.NumMarkers =fread(fid,1,'int16');             %2      number of markers
H.SamplesPerFrame =fread(fid,1,'int16');        %3      total number of analog measurements per video frame
H.FirstVideoFrame =fread(fid,1,'int16');        %4      # of first video frame
% H.EndVideoFrame =fread(fid,1,'int16');        %5      # of last video frame
H.EndVideoFrame =fread(fid,1,'uint16');         % ES: modified to unsigned (size problem large files)
H.MaxIntGap =fread(fid,1,'int16');              %6      maximum interpolation gap allowed (in frame)
H.Scale =fread(fid,1,'float32');                %7-8    floating-point scale factor to convert 3D-integers to ref system units
H.StartRecord =fread(fid,1,'int16');            %9      starting record number for 3D point and analog data
H.SamplesPerChannel =fread(fid,1,'int16');      %10     number of analog samples per channel
H.VideoHZ =fread(fid,1,'float32');              %11-12  frequency of video data
fseek(fid,2*148,'bof');                         %13-147 reserved for future use
H.LablePointer =fread(fid,1,'int16');           %label and range data pointer

if nargin == 2
    data = H;
    return
end

%---------------------PARAMETER SECTION-------------------------------------
fseek(fid,(pblock-1)*512,'bof');  %the start of the parameter block

%parameter header
fseek(fid,2,'cof');  %ignore the first two bytes of the header
numpblocks = fread(fid,1,'uint8'); %number of parameter blocks
processor = fread(fid,1,'uint8'); %processor type 84 = intel, 85 = DEC (VAX PDP-11), 86 = MIPS processor (SGI/MIPS)
switch processor
    case 84 %intel
        machinetype = 'ieee-le';
    case 85 %DEC (VAX PDP-11)
        machinetype = 'ieee-le';%'vaxd'; %Try vaxd if you run into issues when reading in files
    case 86 %MIPS
        machinetype = 'ieee-be';
end
Pheader.NumberOfBlocks = numpblocks;
Pheader.MachineType = processor;
%getting group list
P = struct;
while 1
    numchar = fread(fid,1,'int8');                  %number of characters in the group name
    id = fread(fid,1,'int8');                       %group/parameter id
    gname = char(fread(fid,abs(numchar),'uint8')'); %group/parameter name

    if strcmp(gname,'EndVideoFrame')
        keyboard
    end
    
    
    index = ftell(fid);                             %this is the starting point for the offset
    nextgroup = fread(fid,1,'int16');               %nextgroup = offset to the next group/parameter
    if numchar < 0;                                 %a negative character length means the group is locked
        islock = 1;
    else
        islock = 0;
    end
    fld = [];                                   %fld = structured field to add to the output
    fld.id = id;                                %fld has fields id and description   
    fld.islock = islock;
    
    if id < 0                                       %groups always have id <0 parameters are always >0  
        dnum = fread(fid,1,'uint8');                %number of characters of the desctription
        desc = char(fread(fid,dnum,'uint8')');      %description of the group/parameter
        fld.description = desc;
        P.(gname)=fld;                              %add the field to the variable P
    else %it is a parameter
        dtype = fread(fid,1,'int8');                %what type of data -1 = char 1 = byte  2 = 16 bit integer 3 = 32 bit floating point
        numdim = fread(fid,1,'uint8');              %number of dimensions (0 to 7 dimensions)        
        fld.datatype = dtype;                       %data type of the parameter -1=character, 1=byte, 2=integer, 3= floting point, 4=real
        fld.numberDIM = numdim;                     %number of dimensions (0-7) 0 = scalar, 1=vector, 2=2D matrix,3=3D matrix,...etc 
        fld.DIMsize = fread(fid,numdim,'uint8');    %size of each dimension eg [2,3]= 2d matrix with 2 rows and 3 columns
        dsize = fld.DIMsize';                       %the fread function only reads row vectors
        
        if isempty(dsize)                           %if dsize is empty then we read a scalar
            dsize = 1;
        end            
        if length(dsize) > 2
            dsize = prod(dsize);                    %fread can only handle up to 2 dimensions
        end                                         %if it is greater than 2 dimensions, then just read all data in a single vector.

        switch dtype
            case -1 %character data
                pdata = char(fread(fid,dsize,'uint8'));
            case 1 %byte data  !!!Not tested
                pdata = fread(fid,dsize,'bit8');
            case 2 %16 bit integer
                if strcmp(gname,'FRAMES')
                    pdata = fread(fid,dsize,'uint16',machinetype); % ES: quick and dirty fix for invalid size problem
                else
                    pdata = fread(fid,dsize,'int16',machinetype);
                end
            case 3 %32 bit floating point
                pdata = fread(fid,dsize,'float32',machinetype);
            case 4 %REAL data
                pdata = fread(fid,dsize,'float32',machinetype);
        end
        dnum = fread(fid,1,'uint8');             %number of characters in the description
        desc = char(fread(fid,dnum,'uint8')');      %description string
        fld.description = desc;        
        fld.data = pdata;                            %add data to parameter structured var
        P = setparameter(P,gname,fld);              %add parameter to the appropriate group
    end
    if nextgroup == 0
        break
    end
    fseek(fid,index+nextgroup,'bof');               %go to next group/parameter.

end
data.Header = H;
data.ParameterHeader = Pheader;
data.Parameter = P;

%------------------------3D & Analog DATA SECTION----------------

%first position
fseek(fid,(data.Parameter.POINT.DATA_START.data-1)*512,'bof');
%Analogue data parameters
if isfield(data.Parameter,'ANALOG')
    numAnalogue = data.Parameter.ANALOG.USED.data;
    Alabels = cellstr(data.Parameter.ANALOG.LABELS.data');
    Ascale = data.Parameter.ANALOG.SCALE.data;
   Gscale = data.Parameter.ANALOG.GEN_SCALE.data;
    Aoffset = data.Parameter.ANALOG.OFFSET.data;
%   issigned = data.Parameter.ANALOG.FORMAT.data';            %comment 161, 162,163,164,166 if error
%     if strcmp(issigned,'SIGNED');
%         issigned = 1;
%     else
        issigned = 0;
%   end    



else
    numAnalogue = 0;
    Alabels = [];
    Ascale = [];
    Gscale = [];
    Aoffset = [];
end



%Video (3D) data parameters
numVideo = data.Parameter.POINT.USED.data;
if isfield(data.Parameter.POINT,'LABELS');
    Vlabels = cellstr(data.Parameter.POINT.LABELS.data');
else
    Vlabels = {};
end    
Vscale = data.Parameter.POINT.SCALE.data;
numFrames = data.Parameter.POINT.FRAMES.data;

inc = 4*numVideo+H.SamplesPerFrame;  
%inc is the increment.  Increment is the number of elements in a video
%frame and this consist of:
%The number of Video Channels*4 (xdata,ydata,zdata,and residual) + The
%number of Analogue Measurements per frame;
%Note: the number of Analogue Measurements does NOT always equal the number
%of analogue channels.


%Begin to read the numbers
numdatapts = numFrames*inc;
%number of data points to read this is:
%(Number of frames)*(Number of data per frame)
                                                    
                                                  
%READING the DATA
if Vscale >= 0   %integer format
    AVdata = fread(fid,numdatapts,'int16',machinetype);
else            %floating point format
    AVdata = fread(fid,numdatapts,'float32',machinetype);
end
    

V = struct;
%data for all Video channels
offset = 1;
for i = 1:numVideo
    xd = AVdata(offset:inc:end);
    yd = AVdata(offset+1:inc:end);
    zd = AVdata(offset+2:inc:end);
    residual = AVdata(offset+3:inc:end);
    if i > length(Vlabels)
        Vdata.label = ['MRK ',num2str(i)];
    else
        Vdata.label = Vlabels{i};
    end
    indx = findzeros([makecolumn(xd),makecolumn(yd),makecolumn(zd)]);
    Vdata.xdata = videoconvert(xd,Vscale,indx);
    Vdata.ydata = videoconvert(yd,Vscale,indx);
    Vdata.zdata = videoconvert(zd,Vscale,indx);
    Vdata.residual = residual;
    offset = offset+4;
    V.(['channel',num2str(i)]) = Vdata;    
end

offset = 4*numVideo;  %offset is a pointer to the first data point of the first channel of Analog data
A = struct;
for i = 1:numAnalogue 
    Adata.label = Alabels{i};
    Aframedata = [];
    %A given analog channel can have multiple samples per frame of video
    for j = 0:H.SamplesPerChannel-1 
        stindx = offset+i+j*numAnalogue;
        plate = AVdata(stindx:inc:end);
        Aframedata = [Aframedata,plate];
    end
    Adata.data = analogconvert(merge(Aframedata),Aoffset(i),Ascale(i),Gscale,issigned);  %recombine the multiple samples to one vector
    A.(['channel',num2str(i)]) = Adata;
end
    
data.VideoData = V;
data.AnalogData= A;
    
fclose(fid);


function r = setparameter(g,name,info)
%this function will add a parameter to the appropriate group (based on the
%id)  Note if no group is found, the parameter will not be added.
fld = fieldnames(g);
r = g;
for i = 1:length(fld)
    d = getfield(g,fld{i});
    if abs(info.id) == abs(d.id);
        r = setfield(g,validfield(fld{i}),setfield(d,validfield(name),info));
        break
    end
end

function r = merge(data)
%this function will recombine the analogue data because the potential for multiple
%samples per frame of video.
%each row of "data" corresponds to a single video frame; 
[rw,cl] = size(data);
r = zeros(rw*cl,1);
for i = 1:cl
    r(i:cl:end) = data(:,i);
end

function r = videoconvert(data,scale,indx)
%convert the video channels to real data values
if scale >0
    r = data*scale;
else
    r = data;
end
r(indx) = NaN;

function r = analogconvert(data,offset,chscale,gscale,issigned)
%convert analog channesl to real data values
if ~issigned
    data = unsign(data);
end
r = (data-offset)*chscale*gscale;

function r = unsign(data)
indx = find(data<0);
data(indx) = 2^16+data(indx);
r = data;

function r = getmachinecode(fname)
fid = fopen(fname,'r');
pblock=fread(fid,1,'int8')-1;         %getting the 512 block number where the paramter section is located block 1 = first 512 block of the file
fseek(fid,pblock*512+3,'bof');
r = fread(fid,1,'uint8');
fclose(fid);

function r = findzeros(data)
indx = find(data(:,1)==0);
for i = 2:3
    nindx = find(data(:,i)==0);
    indx = intersect(indx,nindx);
end
    
r = indx;    