function data_out = apply_filter(filter_fname, data_in, fs_in)
% apply a particular filter, the info for which is saved in filter_fname,
% to a signal.  Note that the data must be converted to the sampling rate
% of the filter and back. 

% load filter file.
if exist(fullfile(generate_filters_path, filter_fname))
    filter_data = load(fullfile(generate_filters_path, filter_fname));
else
    error(['filter file ', load(fullfile(generate_filters_path, filter_fname)), 'does not exsist'])
end

% adjust incoming data to data of sampling rate
div = gcd(round(fs_in), round(filter_data.fs));
p = round(fs_in) / div;
q = round(filter_data.fs) / div;
data_filt = resample(data_in, p,q);

% filter data
data_filt = filter(filter_data.a, filter_data.b, data_filt);

% re-resample back to the original fs
data_out = resample(data_filt, q, p);

% normalize so that the max of data out is the same as max(data_in)
data_out = data_out / max(abs(data_out)) * max(abs(data_in));
% 
plot(data_in);
hold on;
plot(data_out, 'r')





