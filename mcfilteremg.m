function out = mcfilteremg(emgdata, filterfreqs)
% Filters EMG data.
%
% syntax
% out = mcfilteremg(emgdata);
% out = mcfilteremg(emgdata, filterfreqs);
%
% input parameters
% emgdata: norm data structure containing EMG data
% filterfreqs: cutoff frequencies (in Hz) for the Butterworth filters; first value for high-pass filter,
%   second value for low-pass filter (default: [20 24])
%
% output
% out: norm data structure containing filtered data
%
% examples
% out = mcfilteremg(emgdata);
% out = mcfilteremg(emgdata, [18 21]);
%
% comments
% Filters the data using a 4th order Butterworth high-pass filter (default cutoff frequency: 20 Hz),
% then full-wave rectifies it,
% then filters it using a 4th order Butterworth low-pass filter (default cutoff frequency: 24 Hz).
%
% see also
% mcreademg
%
% Part of the Motion Capture Toolbox, Copyright 2022,
% University of Jyvaskyla, Finland

out=[];

if ~isfield(emgdata,'type') || ~strcmp(emgdata.type, 'norm data')
    disp([10, 'The first input argument has to be a variable with norm data structure.', 10]);
    [y,fs] = audioread('mcsound.wav');
    sound(y,fs);
    return
end


if nargin==1
    hpf = 20;
    lpf = 24;
else
    if ~isnumeric(filterfreqs) || length(filterfreqs)~= 2
        disp([10, 'The second input argument has to be a numeric array of the size of two.', 10]);
        [y,fs] = audioread('mcsound.wav');
        sound(y,fs);
        return
    end
    hpf = filterfreqs(1);
    lpf = filterfreqs(2);
end

hpf= hpf * 0.8970; % to compensate for filtering frequency shift due to two-pass filtering
lpf = lpf * 1.1155; % same here

out = emgdata;

fs=emgdata.freq;

Wn_hp=hpf/(fs/2);
Wn_lp=lpf/(fs/2);

[b_hp a_hp]=butter(4,Wn_hp,'high');
[b_lp a_lp]=butter(4,Wn_lp);

out1=filtfilt(b_hp,a_hp,emgdata.data);
out2=abs(out1);
out.data=filtfilt(b_lp,a_lp,out2);
