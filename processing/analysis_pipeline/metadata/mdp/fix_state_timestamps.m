function [snr_time_fixed, stats] = ...
    fix_state_timestamps(method, snr_time, mdp_states, ...
    last_idx_before_skip, folder_log)

onset_window = 3600; % 1 hour

if strcmp(method, 'ttrig')
    % specific to this method: find points where the ttrig column increased
    ts_idx = find(diff(mdp_states.ttrig) > 1e-5) - 1;
    if ts_idx(1) == 0
        ts_idx_rep = ts_idx(2:end);
    else
        ts_idx_rep = ts_idx;
    end
    unique(mdp_states.type(ts_idx_rep))
    
    % these are the increased ttrig times
    ts_mdp = mdp_states.ttrig(ts_idx + 2);
    results = find_onset_shift_ttrig(snr_time, ts_mdp, ...
        ts_idx, onset_window);
    [~, idx_match] = min(results.outliers);
elseif strcmp(method, 'strig')
    results = find_onset_shift_strig(snr_time, mdp_states.strig, ...
        onset_window);
    idx_match = find((results.std < .001) & (results.normr < 1), 1, 'first');
end


if any(idx_match)
    results.chosen(idx_match) = true;
    stats.onset = results;
    
    start_snr = results.start_t1(idx_match);
    start_mdp = results.start_t2(idx_match);
    
    if strcmp(method, 'ttrig')
        snr_time_fixed = [snr_time(start_snr) + zeros(start_mdp - 1, 1); ...
            snr_time(start_snr:end)];
        
    elseif strcmp(method, 'strig')
        
        if start_snr > start_mdp
            snr_time_fixed = snr_time((1 + start_snr - start_mdp):end);
            log_msg(folder_log, 'snr-state-info', ...
                sprintf('removing first %d SnR state triggers', ...
                start_snr - start_mdp));
        elseif start_mdp > start_snr
            snr_time_fixed = [repmat(start_snr(1), start_mdp - start_snr, 1); ...
                snr_time];
            log_msg(folder_log, 'snr-state-info', ...
                sprintf('adding %d SnR state triggers in the beginning', ...
                start_mdp - start_snr));
        end
    end
    
    if any(last_idx_before_skip)
        last_idx_before_skip = ...
            last_idx_before_skip - start_snr + start_mdp;
    end
    
else
    err_str = 'unable to find correct start alignment of state events';
    log_msg(folder_log, 'snr-state-error', err_str);
    error(err_str);
end

if any(last_idx_before_skip)
    
    if strcmp(method, 'ttrig')
        
        [snr_time_filled, stats_fill, log_msgs] = ...
            fill_after_skip_ttrig(mdp_states, snr_time_fixed, ...
            last_idx_before_skip);
    elseif strcmp(method, 'strig')
        [snr_time_filled, stats_fill, log_msgs] = ...
            fill_after_skip_strig(mdp_states.strig, snr_time_fixed, ...
            last_idx_before_skip);
    end
    
    stats.fill = stats_fill;
    
    for i = 1:length(log_msgs)
        log_msg(folder_log, 'snr-state-fill', log_msgs{i})
    end
    
    if any(snr_time_filled)
        snr_time_fixed = snr_time_filled;
    else
        ttstr = 'filling snr time stamps by zeros failed';
        log_msg(folder_log, 'snr-state-error', ttstr);
        error(ttstr);
    end
end