function par = mcinitcouplingpar

par.t1=0; % start of analysis window
par.t2=0; % end of analysis window
par.pcind=1:5; % indices for PCs retained
par.scale=.3; % scaling for visualizing
par.myproj=sin(2*pi*linspace(0,1,121))'; % back-projection function
par.binsizetype='auto';
par.binvalue=0;
