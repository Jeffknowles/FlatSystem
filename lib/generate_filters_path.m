function path = generate_filters_path()
path = which('generate_filters_path');
idx = strfind(path, fullfile('FlatSystem', 'lib'));
path = fullfile(path(1:idx+9), 'filters');