% Motion Capture Toolbox -- Copyright University of Jyvaskyla, Finland
% Version 1.5 / 31-July-2015
%
% I/O & EDIT FUNCTIONS
% mcread -- reads MoCap data files
% mcreademg -- reads emg files in tsv format
% mcmissing -- reports missing frames and markers
% mctrim -- extracts a temporal segment from MoCap data
% mccut -- cuts two MoCap structures to the length of the shorter one
% mcaddframes -- duplicates frames
% mcsetlength -- sets mocap data to the length given
% mcsmoothen -- smoothens MoCap data
% mcmerge -- merges two MoCap data structures
% mcsort -- sorts mocap data according to marker names
% mcgetmarker -- extracts a subset of markers from MoCap data
% mcsetmarker -- replaces a subset of markers
% mcconcatenate -- concatenates markers from different MoCap or norm data structure
% mcgetmarkername -- gets names of markers from MoCap data
% mcfillgaps -- fills missing data
% mcinitstruct -- initializes "empty" Mocap or norm data structure
% mcreorderdims -- reorders the Euclidean dimensions in the MoCap data
% mcreverse -- reverse dimensions of mocap data
% mcresample -- resamples motion capture data
% mcrepovizz -- exports mocap structure as repoVizz files
% mcc3d2tsv -- converts c3d into tsv file
% mcwritetsv -- saves a mocap structure as tsv file
%
% TRANSFORMATION FUNCTIONS
% mccenter -- centers MoCap data to have a mean of [0 0 0]
% mctranslate -- translates MoCap data
% mcrotate -- rotates MoCap data
% mc2frontal -- rotates MoCap data to have a frontal view with respect to a pair of markers
% mcvect2grid -- convert a MoCap structure vector to a MoCap structure with three orthogonal views
%
% COORDINATE SYSTEM CONVERSION FUNCTIONS
% mcinitm2jpar -- initializes parameters for marker-to-joint mapping
% mcm2j -- performs a marker-to-joint mapping
% mcinitj2spar -- initializes parameters for joint-to-segment mapping
% mcj2s -- performs a joint-to-segment mapping
% mcs2j -- performs a segment-to-joint mapping
% mcs2posture -- create a posture representation form segm data
%
% KINEMATIC ANALYSIS FUNCTIONS
% mcnorm -- calculates the norms of Euclidean MoCap data
% mctimeder -- estimates time derivatives of MoCap data
% mctimeintegr -- estimates time integrals of MoCap data
% mccumdist -- calculates the cumulative distance traveled by each marker
% mcmarkerdist -- calculates the distance of a marker pair
% mcboundrect -- calculates the bounding rectangle
% mccomplexity -- calculate the complexity of movement
% mcfluidity -- calculate the fluidity/circularity of mocap data
% mcrotationrange -- calculates rotation range between two markers
% mcsegmangle -- calculates the angles between two markers
% mcperiod -- estimates movement periods of MoCap data
% mcdecompose -- decomposes kinematic variable into tangential and normal components
% mcspectrum -- calculates amplitude spectrum of MoCap data
%
% KINETIC ANALYSIS FUNCTIONS
% mcgetsegmpar -- returns segment parameters of a body model
% mckinenergy -- estimates instantaneous kinetic energy of the body
% mcpotenergy -- estimates instantaneous potential energy of the body
%
% TIME-SERIES ANALYSIS FUNCTIONS
% mcmean -- calculates mean of MoCap data
% mcstd -- calculates std of MoCap data
% mcvar -- calculates variance of MoCap data
% mcskewness -- calculates skewness of MoCap data
% mckurtosis -- calculates kurtosis of MoCap data
% mcstatmoments -- calculates first four statistical moments
% mcwindow -- performs windowed time-series analysis
%
% VISUALIZATION FUNCTIONS
% mcplottimeseries -- plots time series data
% mcplotphaseplane -- creates phase plane plots
% mcinitanimpar -- initializes animation parameters
% mccreateconnmatrix: creates connection matrix for plotting and animations
% mcplotframe -- plots jpeg frames from MoCap data
% mcanimate -- plots and saves jpeg frames for animation
% mcsimmat -- calculate similarity matrix
% mcmocapgram -- plots mocapgram
%
% PROJECTION FUNCTIONS
% mcpcaproj -- performs a Principal Components Analysis
% mcicaproj -- performs an Independent Component Analysis
% mcsethares -- performs either an m-best or a small-to-large Sethares transform
% mceigenmovement -- returns eigenmovements obtained from Principal Components Analysis
%
% OTHER FUNCTIONS
% mcbandpass -- band pass filters MoCap data
% mchilbert -- performs a Hilbert transform
% mchilberthuang -- performs a Hilbert-Huang transform
% mcfilteremg -- filter emg data
