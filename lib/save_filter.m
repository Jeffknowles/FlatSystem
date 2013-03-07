function save_filter(filter_name, a, b, fs, hdmag)

save(fullfile(generate_filters_path, filter_name), 'a', 'b', 'fs', 'hdmag');
