function result_table = find_onset_shift_strig(ts1, ts2, use_window)

% JN 2019-07-01

% simple function that uses the 'diff of diff' statistic to find the best
% onset shift of two time series

% script assumes that ts1 and ts2 are in seconds
% use_window is the time to be used at the beginning of the session, in
% seconds

max_shift = 5;
outlier_border = .02;

idx = ts1 < ts1(1) + use_window;
ts1 = ts1(idx);
ts2 = ts2(1:length(ts1));

results = zeros(max_shift^2, 8);
c_count = 1;

for start_t1 = 1:max_shift
    for start_t2 = 1:max_shift
        tt1 = ts1(start_t1:end);
        tt2 = ts2(start_t2:end);
        msize = min([length(tt1) length(tt2)]);
        tt1 = tt1(1:msize);
        tt2 = tt2(1:msize);
        stat = diff(tt1) - diff(tt2);
        [p, S] = polyfit(tt1, tt2, 1);
        outliers = sum(abs(stat) > outlier_border);
        stat_mean = mean(stat);
        stat_std = std(stat);
        results(c_count, 1:7) = [start_t1 start_t2 stat_mean ...
            stat_std p(1) S.normr outliers];
        c_count = c_count + 1;
    end
end

result_table = array2table(results, 'VariableNames',...
    {'start_t1', 'start_t2', 'mean', 'std', ...
    'slope', 'normr', 'outliers', 'chosen'});