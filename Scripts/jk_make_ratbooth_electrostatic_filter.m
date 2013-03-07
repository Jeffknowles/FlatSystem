%% make filter for ratbooth.  

clear all; close all; clc;



% read in stimulus
daq_data = load('4k to 36k linear fmsweepwith EC speaker 3_4_13.mat');

% read in stimuli
stimulus_wf = daq_data.Ch1.values(3e5:5e5);
response_wf = daq_data.Ch2.values(3e5:5e5);

% get rid of dc offsets
stimulus_wf = stimulus_wf - mean(stimulus_wf);
response_wf=response_wf-mean(response_wf);

% no params - enter params
params.fs=round(1/daq_data.Ch1.interval);
params.fmax=36e3;
params.fmin=4e3;
params.dur= 2;
params.t_start=0.24000;
params.t_stop= 2.24;


[a, b, hdmag] = generate_filter(stimulus_wf, response_wf, params, 'plot', false);
save_filter('test_electrostatic', a, b, params.fs, hdmag);

