function [amp, phase, h] = mchilbert(d, wrap)
% Calculates the Hilbert transform of data in a MoCap or norm structure.
% 
% syntax
% [amp, phase, h] = mchilbert(d, wrap);
% 
% input parameter
% d: MoCap or norm data structure
% wrap: flag to indicate if phase is returned as wrapped or unwrap (default: unwrapped); 0 or empty: unwrap, 1: wrap
% 
% output
% amp: amplitude of analytic function derived from zero-mean signal
% phase: (wrapped or unwrapped) phase of analytic function derived from zero-mean signal
% h: analytic function
% 
% examples
% amp = mchilbert(d);
% [amp, phase, h] = mchilbert(d, 1);
%
% comments
% See help hilbert
% 
% Part of the Motion Capture Toolbox, Copyright 2008, 
% University of Jyvaskyla, Finland

if nargin == 1  %adapted BB20140317
    wrap=0;
end

amp=[];
phase=[];
h=[];

if wrap~=0 && wrap~=1
    disp([10, 'Second input argument has to be either 0 or 1.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end

if isfield(d,'type') && (strcmp(d.type, 'MoCap data') || strcmp(d.type, 'norm data'))
    amp=d; %amp.type = 'norm data'; %BBFix20150716; keep data structure
    phase=d; %phase.type = 'norm data'; 
    h=d; %h.type = 'norm data'; 
    m = mean(d.data); 
    d.data = d.data - repmat(m,size(d.data,1),1);
    h.data = hilbert(d.data);
    amp.data = abs(h.data);
    if wrap==0; %BBAdd20140317
        phase.data = unwrap(angle(h.data));
    else phase.data = angle(h.data);
    end
    h.data = h.data + repmat(m,size(h.data,1),1);
else
    disp([10, 'The first input argument has to be a variable with MoCap or norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
end
