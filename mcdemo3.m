function mcdemo3
% This example shows how you can estimate kinematic
% variables from MoCap data and visualize them
%
% Time derivatives of motion-capture data can be estimated 
% using the mctimeder function:
load mcdemodata
d2v = mctimeder(dance2, 1); % velocity
d2a = mctimeder(dance2, 2); % acceleration

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

% Let us have a look at the vertical velocity component 
% of markers 1, 19, and 25 (head, hand, and foot)

figure, set(gcf,'Position',[40 200 560 420])
mcplottimeseries(d2v, [1 19 25], 'dim', 3)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Next, let us plot the vertical acceleration components 
% of the same markers

clf
mcplottimeseries(d2a, [1 19 25], 'dim', 3)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The phase plane plot for velocity and acceleration can be 
% produced as follows

clf
set(gcf,'Position',[40 40 200 800])
mcplotphaseplane(d2v, d2a, [1 19 25], 3)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Here is the same phase plane plot, but for the interval 
% between 5 and 7 seconds

clf
mcplotphaseplane(mctrim(d2v,5,7), mctrim(d2a,5,7), [1 19 25], 3)

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The cumulative distance tavelled by a marker can be calculated
% with the function mccumdist

d2dist=mccumdist(dance2);

% Let us have a look at the distance travelled by
% markers 1, 19, and 25 (head, hand, and foot):

clf, set(gcf,'Position',[40 200 560 420])
mcplottimeseries(d2dist, [1 19 25])

% As we can see, the head has travelled ca. 13 meters, the hand ca. 33
% meters, and the foot ca. 11 meters

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Periodicity of movement for can be estimated using the 
% mcperiod function. Let us estimate the periodicity of
% the movement of marker 1 (left front head) in the three
% dimensions.
close
d2m1 = mcgetmarker(dance2, 1);
[per, ac, eac, lag] = mcperiod(d2m1, 2); % maximal period = 2 sec

per

% There is thus no periodic movement in the horizontal direction, but a
% period of 0.51 seconds in the vertical direction

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The autocorrelation function for the vertical location 
% of marker 1 looks like this:

figure, set(gcf,'Position',[40 200 560 420])
plot(lag, ac(:,3)), xlabel('Period / secs')

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% ... and the enhanced autocorrelation function like this:
% Notice the peak at 0.51 secs

clf
plot(lag, eac(:,3)), xlabel('Period / secs')

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% More accurate periodicity analysis can be done using windowed
% autocorrelation

[per, ac, eac, lags, wtime] = mcwindow(@mcperiod, d2m1, 2, 0.25);

% Let us plot the estimates for periodicity in vertical movement
% for each of the windows

clf
plot(wtime, per(:,3))
xlabel('Time / secs')
ylabel('Period /secs')

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% The enhanced autocorrelation matrix can be plotted as an
% image to allow visual inspection of the time development
% of periodicity:

imagesc(eac(:,:,3)), axis xy
set(gca,'XTick',0:4:46)
set(gca,'XTickLabel',0.5*(0:4:46))
set(gca,'YTick',[0 30 60 90 120])
set(gca,'YTickLabel',[0 0.5 1 1.5 2.0])
xlabel('Time / secs')
ylabel('Period /secs')

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
