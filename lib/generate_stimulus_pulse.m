function [wf, params] = generate_stimulus_pulse(fs, fmax, fmin, dur, padding)

stimgen_params.Fs = fs;
stimgen_params.f1i = fmax;
stimgen_params.f1t = fmin;
stimgen_params.DUR = dur;
stimgen_params.sweeptype = 'lfm';
stimgen_params.nharm = 1;

% generate pulse
wf = pulsegen(stimgen_params);
wf = set_rms_for_krank(wf, 85);
% add padding
wf = zero_pad(wf, fs, padding/4, padding);


% add noise -90 db
wf = wf + randn(size(wf)) * 10^(-90/20);

params.fs = fs;
params.fmax = fmax;
params.fmin = fmin;
params.dur = dur;
params.t_start = padding/4;
params.t_stop = padding/4 + dur;
