function mcdemo4
% This example shows how you can do various
% statistical analyses on time-series data
% using the functions provided in the MoCap
% toolbox
%
% The first statistical moments, mean, standard
% deviation, skewness, and kurtosis, can be calculated 
% using the functions mcmean, mcstd, mcskewness, 
% and mckurtosis, respectively. These functions
% ignore eventual missing frames.
%
pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us calculate the standard deviations for the
% markers 1, 19, and 25 (head, hand, and foot) in
% the Mocap strcutures dance1 and dance2:

load mcdemodata
std1 = mcstd(mcgetmarker(dance1, [1 19 25]));
std2 = mcstd(mcgetmarker(dance2, [1 19 25]));
figure, set(gcf,'Position',[40 200 560 420])
subplot(2,1,1)
bar(reshape(std1,3,3)), xlabel('Dimension')
legend('Head', 'Hand', 'Foot'), axis([-Inf Inf 0 400])
title('dance1')
subplot(2,1,2)
bar(reshape(std2,3,3)), xlabel('Dimension')
legend('Head', 'Hand', 'Foot'), axis([-Inf Inf 0 400])
title('dance2')

% The standard deviations for the dimensions 1 and 2
% are larger for dance1 than for dance2, suggesting that
% dancer 1 occupies a larger area horizontally. The standard
% deviation for dimension 3 for the hand marker is larger for 
% dance1, suggesting that dancer 1 uses larger vertical hand 
% movements.

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Let us calculate and plot the skewness values for the vertical
% dimension of selected markers for dance1, dance2, walk1 and walk2.

marker = [1 9 19 21 25];
d1skew = mcskewness(mcgetmarker(dance1, marker));
w1skew = mcskewness(mcgetmarker(walk1, marker));
d2skew = mcskewness(mcgetmarker(dance2, marker));
w2skew = mcskewness(mcgetmarker(walk2, marker));
mn = mcgetmarkername(dance1);
subplot(2,2,1)
bar(d1skew(3:3:end)), set(gca,'XTickLabel', [mn{marker}])
title('dance1'), axis([-Inf Inf -2 3])
subplot(2,2,2)
bar(d2skew(3:3:end)), set(gca,'XTickLabel', [mn{marker}])
title('dance2'), axis([-Inf Inf -2 3])
subplot(2,2,3)
bar(w1skew(3:3:end)), set(gca,'XTickLabel', [mn{marker}])
title('walk1'), axis([-Inf Inf -2 3])
subplot(2,2,4)
bar(w2skew(3:3:end)), set(gca,'XTickLabel', [mn{marker}])
title('walk2'), axis([-Inf Inf -2 3])

% There are some differences between dancing and walking
% with respect to the skewness values. The interpretation
% of these differences will be left to the user.

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%
clc
% Windowed analysis of the statistical time-series descriptors
% can be carried out using the mcwindow command.
% 
% Let us compute the windowed standard deviation of markers 
% 1, 19, and 25 (head, hand, and foot) in the Mocap 
% structure dance1:

marker = [1 19 25];
d1std=mcwindow(@mcstd, mcgetmarker(dance1, marker), 2, 0.25);
for k=1:9
    subplot(3,3,k), plot(d1std(:,k)), title(['Marker ' num2str(marker(1+floor((k-1)/3))) ', dim. ' num2str(1+rem(k-1,3))])
end

% High values in these graph correspond to temporal regions
% where the particular marker shows wide movements for 
% the respective dimension

pause %%%%%%%%%%% hit a key to continue %%%%%%%%%%%%%%%%%%%%%%%%%%

close
