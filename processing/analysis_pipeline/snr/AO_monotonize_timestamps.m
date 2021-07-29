function [snr_times, to_add_all] = AO_monotonize_timestamps(snr_times)
% JN 2020-05-08 (75 years Victory in Europe)

% make sure file is sorted by file number already
if ismember('DatedFromFileNo', snr_times.Properties.VariableNames)
    sort_column = snr_times.DatedFromFileNo;
else
    sort_column = snr_times.FromFileNo;
end


assert(all(diff(sort_column) >= 0));

% find break positions (i.e., row before a break)
idx_file_num_change = find(diff(sort_column) > 0);

% durations of breaks
break_times = snr_times.Time(idx_file_num_change + 1) - ...
    snr_times.Time(idx_file_num_change);


nums = unique(sort_column);

to_add_all = zeros(length(nums), 2);
to_add_all(:, 1) = nums;

to_add_now = 0;

for i_num = 2:length(nums)
    if break_times(i_num - 1) <= 0
        
        % additionally add a 5 minute break here
        to_add_now = to_add_now + ...
            snr_times.Time(idx_file_num_change(i_num - 1)) + 300;
    end
    to_add_all(i_num, 2) = to_add_now;

end

for i_num = 1:length(nums)
    idx = sort_column == nums(i_num);
    snr_times.Time(idx) = snr_times.Time(idx) + to_add_all(i_num, 2);
end

to_add_all = array2table(to_add_all, 'VariableNames', ...
    {'snr_file_num', 'time_to_add'});