%% generate_krank_filter
clear all; close all; clc;

% read in stimulus
daq_data = load('bs_speaker_ec1_1k_to_46k_sweep_bnk_mic_amp.mat');

% extract wfs
stimulus_wf = daq_data.Ch1.values;
response_wf = daq_data.Ch2.values;

% get rid of dc offsets
stimulus_wf = stimulus_wf - mean(stimulus_wf);
response_wf=response_wf-mean(response_wf);

% enter params
params.fs=round(1/daq_data.Ch1.interval);
params.fmax=46e3;
params.fmin=1e3;
params.dur= 3;
params.t_start=1.195e5/params.fs;
params.t_stop=params.t_start + params.dur;

% generate filter and save
[a, b, hdmag] = generate_filter(stimulus_wf, response_wf, params, 'plot', true);
save_filter('bs_electrostatic', a, b, params.fs, hdmag);

