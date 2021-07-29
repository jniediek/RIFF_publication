function  last_idx_before_skip = find_skipped_mpx_file(snr_table)

% JN 2019-06-10
% check if there is a "lost .mpx file" and return last "sane" index

if ismember('DatedFromFileNo', snr_table.Properties.VariableNames)
    sort_column = snr_table.DatedFromFileNo;
else
    sort_column = snr_table.FromFileNo;
end

fnum_diff = diff(sort_column);
t_num = sort_column(find(fnum_diff > 1, 1, 'first'));

if ~any(t_num)
    last_idx_before_skip = [];
else
    last_idx_before_skip = find(sort_column == t_num, 1, 'last');
end