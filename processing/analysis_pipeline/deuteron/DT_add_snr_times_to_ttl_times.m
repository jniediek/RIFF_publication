function times = DT_add_snr_times_to_ttl_times(ttl_times, snr_times, ...
    log_folder)

% JN 2020-05-04, 2020-05-10

if length(ttl_times) ~= length(snr_times)
    log_msg(log_folder, 'fit-ttl-snr-error', ...
        'No mechanism for fitting Deuteron TTL with SnR times active')
    times = [];
    % JN 2020-05-04
    % I removed the old "nearest neighbor interpolation" fixing algorithm
    % here because we had no idea how well it worked.
    % We'll have to talk about this point.
else
    ttl_times = ttl_times/1000;
    % calculate goodness of fit by polyfit

    [p, S] = polyfit(ttl_times, snr_times, 1);
    stat = max(abs(diff(ttl_times) - diff(snr_times)));
    msg = sprintf('fitting slope %.3f, norm %.3f, max diff %.3f ms', ...
        p(1), S.normr, stat*1000);
    log_msg(log_folder, 'fit-ttl-snr', msg);
    times = snr_times;
    
    % put a warning if stat is too big, e.g. > 1 ms
end