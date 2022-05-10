function mcdemo11
% This example shows how movement data collected with the
% Nintendo Wii controller can be analyzed using the
% Toolbox.
%
% The toolbox supports the file format used by
% the WiiDataCapture software, available at 
% http://www.jyu.fi/music/coe/materials.

load mcdemodata

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The variable 'wiidata' contains acceleration data captured
% using the Nintendo Wii controller:
wiidata
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us plot the third acceleration component of the data
mcplottimeseries(wiidata,1,'dim',3)
set(gcf,'Position', [40 20 1400 200])
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The data is somewhat noisy, so we smoothen it a bit:
wd2 = mcsmoothen(wiidata,25);
mcplottimeseries(wd2,1,'dim',3)
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us do a windowed analysis of the period of this acceleration
% component using a window length of 2 seconds and a hop factor of
% 0.25:
[per, ac, eac, lags, wstart] = mcwindow(@mcperiod, wd2, 2, 0.25);
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Next, let us plot the estimated period of the third component
% as a function of the starting point of the window:
plot(wstart,per(:,3))
set(gcf,'Position',[40 200 560 420])
xlabel('Time / s')
ylabel('Period / s')
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% A similar representation can be obtained by plotting
% the enhanced autocorrelation image:
imagesc(eac(:,:,3)), axis xy
set(gcf,'Position',[40 200 560 420])
set(gca,'XTick',0:2:32)
set(gca,'XTickLabel',0.5*(0:2:32))
set(gca,'YTick',[1 51 101 151 201])
set(gca,'YTickLabel',[0 0.5 1 1.5 2.0])
xlabel('Time / secs')
ylabel('Period /secs')
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
close
