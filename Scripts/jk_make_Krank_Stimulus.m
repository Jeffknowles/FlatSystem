% make tuning stimulus for krank (birdsong) system
close all; clear all; clc

fs = 40e3;
fmax = 18e3;
fmin = 200;
dur = 4;
padding = 2;

direc = '/data/doupe_lab/stimuli/krank_tuning/';
mkdir(direc);
fname = 'lfmd_stim.raw';

[wf, params] = generate_stimulus_pulse(fs, fmax, fmin, dur, padding);
return
%wf = apply_krank_filters(wf,fs);
plot(wf)
write_krank_file(wf,[direc, fname])
save([direc, 'params.mat'],'params')

wf_filt = wf - filter_bandstop(wf, 5e3, 5.1e3, fs)/4; 
wf_filt = vertcat(zeros(2050,1),wf_filt);
wf_filt = wf_filt(1:length(wf));
generate_filter(wf/rms(wf), wf_filt/rms(wf), params);
wavwrite(wf_filt, fs, 'fmsweep.wav');
% plot(wf)
% ap = audioplayer(wf, fs)
% ap.play;
