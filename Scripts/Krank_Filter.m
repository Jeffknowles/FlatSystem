%% generate_krank_filter
close all; clear all; clc;

% read in stimulus
stimulus_wf = read_krank_file('/data/doupe_lab/stimuli/krank_tuning/', 'lfmd_stim.raw','b');
params = load('/data/doupe_lab/stimuli/krank_tuning/params.mat');
params = params.params;

% read in files
response_data = load('/data/doupe_lab/sweep1.mat');
start_idx = 1;
response_wf = response_data.sweep1(start_idx:start_idx+length(stimulus_wf)-1);

% 
% fig = figure('color','w');
% subplot(2,1,1)
% plot(stimulus_wf)
% subplot(2,1,2)
% plot(response_wf)

[a, b] = generate_filter(stimulus_wf, response_wf, params, 'plot', true);
save('filters/filter_20121009.mat','a','b')
