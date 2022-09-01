function segmpar = mcgetsegmpar(model, segm)
% Get parameters for body segments.
%
% syntax
% spar = mcgetsegmpar(model, segm);
%
% input parameters
% model: string indicating the body-segment model used (possible value: 'Dempster',
%   more to be added in the future)
% segm: vector indicating numbers for each segment
%
% output
% spar: segmpar structure
%
% examples
% segmnum = [0 0 8 7 6 0 8 7 6 13 12 10 11 3 2 1 11 3 2 1];
% spar = mcgetsegmpar('Dempster', segmnum);
%
% comments
% Returns the mass relative to total body mass (spar.m),
% relative distance of center of mass from proximal joint (spar.comprox)
% and distal joint (spar.comdist), and radius of gyration relative to
% center of gravity (spar.rogcg), proximal joint (spar.rogprox) and
% distal joint (spar.rogdist) of for body segments indicated in
% segmnum according to given body-segment model.
%
% Segment number values for model 'Dempster': no parameter=0, hand=1, forearm=2,
% upper arm=3, forearm and hand=4, upper extremity=5, foot=6, leg=7, thigh=8,
% lower extremity=9, head=10, shoulder=11, thorax=12, abdomen=13, pelvis=14,
% thorax and abdomen=15, abdomen and pelvis=16, trunk=17, head, arms and trunk
% (to glenohumeral joint)=18, head, arms and trunk (to mid-rib)=19.
%
% references
% Robertson, D. G. E., Caldwell, G. E., Hamill, J., Kamen, G., & Whittlesley, S. N. (2004).
% Research methods in biomechanics. Champaign, IL: Human Kinetics.
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

segmpar=[];

if ~isletter(model)
     disp([10, 'First input argument has to be a string.', 10]);
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     return
end
if ~isnumeric(segm)
     disp([10, 'Second input argument has to be numeric.', 10]);
     [y,fs] = audioread('mcsound.wav');
     sound(y,fs);
     return
end

if strcmp(model,'Dempster')
    md =[.006 .016 .028 .022 .05 .0145 .0465 .1 .161 .081 .0158 .216 .139 .142 .355 .281 .497 .678 .678];
    comproxd =[.506 .43 .436 .682 .53 .5 .433 .433 .447 1 .712 .82 .44 .105 .63 .27 .495 .626 1.142];
    comdistd = 1-comproxd;
    rogcgd =[.298 .303 .322 .468 .368 .475 .302 .323 .326 .495 0 0 0 0 0 0 .406 .496 .903];
    rogproxd =[.587 .526 .542 .827 .645 .69 .528 .54 .56 1.116 0 0 0 0 0 0 .64 .798 1.456];
    rogdistd =[.577 .647 .645 .565 .596 .69 .643 .653 .65 .495 0 0 0 0 0 0 .648 .621 .914];

    segmpar.type = 'segmpar';
    segmpar.m=zeros(1,length(segm)); segmpar.m(find(segm>0))=md(segm(find(segm>0)));
    segmpar.comprox=zeros(1,length(segm)); segmpar.comprox(find(segm>0))=comproxd(segm(find(segm>0)));
    segmpar.comdist=zeros(1,length(segm)); segmpar.comdist(find(segm>0))=comdistd(segm(find(segm>0)));
    segmpar.rogcg=zeros(1,length(segm)); segmpar.rogcg(find(segm>0))=rogcgd(segm(find(segm>0)));
    segmpar.rogprox=zeros(1,length(segm)); segmpar.rogprox(find(segm>0))=rogproxd(segm(find(segm>0)));
    segmpar.rogdist=zeros(1,length(segm)); segmpar.rogdist(find(segm>0))=rogdistd(segm(find(segm>0)));
else
    disp([10, 'Unknown model: ' model])
    disp(['Models included: Dempster. Please choose this one.', 10])
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
