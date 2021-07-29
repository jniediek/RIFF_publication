function snr_times = AO_process_ttls(in_folder, result_folder)


fnames = dir(fullfile(in_folder, '*.mpx'));
n_fnames = size(fnames, 1);

if n_fnames == 0
    log_msg(result_folder, 'no-mpx', ...
        sprintf('No .mpx files found in %s', in_folder));
    error('No .mpx files found in %s', in_folder)
end

% JN 2020-04-23
% the numbers 1:4 and 49:52 correspond to different versions of the SNR
keep_one_idx = [1 2 3 49 50 51]; 
keep_zero_idx = [4 52];

all_results = cell(n_fnames, 1);

parfor i = 1:length(fnames)
    t_name = fnames(i).name;
    file_id = str2double(t_name(end-7:end-4));
    year = str2double(t_name(2:3));
    month = str2double(t_name(4:5));
    day = str2double(t_name(6:7));
    % JN 2020-05-14
    % adding the DatedFromFileNo for cases where one experiment spans more
    % than one calendar day.
    file_id_long = AO_generate_dated_from_file_num(year + 2000, month, ...
        day, file_id);
    fprintf('Starting %s (ID = %d)\n', fnames(i).name, file_id);
    events = AO_extract_ttls_from_mpx(fullfile(in_folder, fnames(i).name));
    keep_idx = zeros(size(events, 1), 1);
    idx1 = events(:, 3) == 1;
    idx0 = events(:, 3) == 0;
    idx_trig1 = ismember(events(:, 1), keep_one_idx);
    idx_trig0 = ismember(events(:, 1), keep_zero_idx);
    keep_idx(idx1 & idx_trig1) = 1;
    keep_idx(idx0 & idx_trig0) = 1;
    events = events(logical(keep_idx), :);
    all_results{i} = [events file_id*ones(size(events, 1), 1) ...
        file_id_long*ones(size(events, 1), 1)];
end

events = vertcat(all_results{:});

% decide which are the relevant fields
n_1 = sum(events(:, 1) == 1);
n_49 = sum(events(:, 1) == 49);

if (n_1 > 10) && (n_49 < 5)
    relevant_fields = 1:4;
elseif (n_1 < 5) && (n_49 > 10)
    relevant_fields = 49:52;
end

relevant_types = {'snd', 'state', 'cam', 'bhv'};

temp = categorical(events(:, 1), relevant_fields, relevant_types);
snr_times = table(events(:, 2), temp, events(:, 4), events(:, 5), ...
    'VariableNames', {'Time', 'EventType', 'FromFileNo', 'DatedFromFileNo'});


breakpoints = find(diff(snr_times.DatedFromFileNo));
start_stop = zeros(0, 3);
count = 1;
current_part = 1;
start = 0;
for i = 1:length(breakpoints)-1
    cur = breakpoints(i);
    dist = snr_times.Time(cur+1) - snr_times.Time(cur);
    if dist > 50
        start_stop(count, :) = [start + 1 cur current_part];
        start = cur;
        current_part = current_part + 1;
        count = count + 1;
    end
end
start_stop(count, :) = [start + 1 height(snr_times) current_part];

all_parts = zeros(height(snr_times), 1);

for i = 1:size(start_stop, 1)
    all_parts(start_stop(i, 1):start_stop(i, 2)) = start_stop(i, 3);
end

snr_times = [snr_times, ...
    table(all_parts, 'VariableNames', {'ExperimentNo'})];

snr_times = sortrows(snr_times, {'DatedFromFileNo', 'Time'});
