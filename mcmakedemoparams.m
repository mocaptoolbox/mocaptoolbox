% marker animation parameters
mapar = mcinitanimpar;
mapar.conn=[1 2;2 4;3 4;3 1;...
    5 6; 9 10;10 12;11 12;11 9;...
    8 9; 8 10;8 5;8 6;...
    5 9;5 11;6 10;6 12;...
    7 11; 7 12;7 5;7 6;...
    5 13;13 15;13 16;16 19;15 19;...
    6 14;14 17;14 18;17 20;18 20;...
    9 21;11 21;10 22;12 22;...
    21 23;23 25;25 26;26 23;...
    22 24;24 27;27 28;28 24];

% joint animation parameters
japar = mcinitanimpar;
japar.conn=[1 2;2 3;3 4;4 5;...
    1 6;6 7;7 8;8 9;...
    1 10;10 11;11 12;...
    11 13;13 14;14 15;15 16;...
    11 17;17 18;18 19;19 20];

% m2j parameters
m2jpar = mcinitm2jpar;

m2jpar.markerName{1} = 'root';
m2jpar.markerNum{1} = [9:12];

m2jpar.markerName{2} = 'lhip';
m2jpar.markerNum{2} = [9 11];

m2jpar.markerName{3} = 'lknee';
m2jpar.markerNum{3} = [21];

m2jpar.markerName{4} = 'lankle';
m2jpar.markerNum{4} = [23];

m2jpar.markerName{5} = 'ltoe';
m2jpar.markerNum{5} = [25 26];

m2jpar.markerName{6} = 'rhip';
m2jpar.markerNum{6} = [10 12];

m2jpar.markerName{7} = 'rknee';
m2jpar.markerNum{7} = [22];

m2jpar.markerName{8} = 'rankle';
m2jpar.markerNum{8} = [24];

m2jpar.markerName{9} = 'rtoe';
m2jpar.markerNum{9} = [27 28];

m2jpar.markerName{10} = 'midtorso';
m2jpar.markerNum{10} = [7 8 7:12];

m2jpar.markerName{11} = 'neck';
m2jpar.markerNum{11} = [5 6];

m2jpar.markerName{12} = 'head';
m2jpar.markerNum{12} = [1:4];

m2jpar.markerName{13} = 'lshoulder';
m2jpar.markerNum{13} = [5];

m2jpar.markerName{14} = 'lelbow';
m2jpar.markerNum{14} = [13];

m2jpar.markerName{15} = 'lwrist';
m2jpar.markerNum{15} = [15 16];

m2jpar.markerName{16} = 'lfinger';
m2jpar.markerNum{16} = [19];

m2jpar.markerName{17} = 'rshoulder';
m2jpar.markerNum{17} = [6];

m2jpar.markerName{18} = 'relbow';
m2jpar.markerNum{18} = [14];

m2jpar.markerName{19} = 'rwrist';
m2jpar.markerNum{19} = [17 18];

m2jpar.markerName{20} = 'lfinger';
m2jpar.markerNum{20} = [20];


m2jpar.nMarkers = length(m2jpar.markerName);


% j2s parameters
j2spar = mcinitj2spar;

j2spar.rootMarker = 1;
j2spar.frontalPlane = [6 2 10];
j2spar.parent = [0 1 2 3 4 1 6 7 8 1 10 11 11 13 14 15 11 17 18 19];

j2spar.segmentName = [{'lhip'},{'lthigh'},{'lleg'},{'lfoot'},...
    {'rhip'},{'rthigh'},{'rleg'},{'rfoot'},...
    {'ltorso'},{'utorso'},{'neck'},{'lshoulder'},{'luarm'},{'llarm'},{'lhand'},...
    {'rshoulder'},{'ruarm'},{'rlarm'},{'rhand'}];

% body segment parameters
spar = mcgetsegmpar('Dempster',[0 0 8 7 6 0 8 7 6 13 12 10 11 3 2 1 11 3 2 1]);
