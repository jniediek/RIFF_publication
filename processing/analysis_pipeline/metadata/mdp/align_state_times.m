function [mdp_states, ts_stats] = ...
    align_state_times(snr_time, last_idx_before_skip, mdp_states, folder_log)

n_mdp_states = height(mdp_states);

msgs = {sprintf('n-mdp-state %d', n_mdp_states), ...
    sprintf('n-snr-state %d', length(snr_time))};

if ismember('strig', mdp_states.Properties.VariableNames)
    method = 'strig';
elseif ismember('ttrig', mdp_states.Properties.VariableNames)
    method = 'ttrig';
else
    error('states have neither strig nor ttrig column, cannot align')
end

msg_method = ['using column ' method ' for SnR timestamp alignment'];

if any(last_idx_before_skip)
    msg_skip = ...
        sprintf('last index before nightly time skip on SnR: %d', ...
        last_idx_before_skip);
else
    msg_skip = sprintf('no nightly time skip detected on SnR');
end

msgs = [msgs msg_skip msg_method];

for i = 1:length(msgs)
    log_msg(folder_log, 'snr-state-info', msgs{i});
end

[snr_time, ts_stats] = fix_state_timestamps(method, ...
    snr_time, mdp_states, last_idx_before_skip, folder_log);

% add or remove timestamps in the end of snr_times to fit lengths
% we currently (July 2019) don't understand why this is sometimes
% necessary at all.

n_snr_times = length(snr_time);
excess_tail = n_mdp_states - n_snr_times;
log_msg(folder_log, 'snr-state-nums', ...
    sprintf('n-snr-state %d, n-mdp-state %d', ...
    n_snr_times, n_mdp_states));

if excess_tail == 0
    msg_1 = 'not modifying SnR state timestamps after insertion of zeros';
elseif excess_tail > 0
    end_ts = snr_time(end);
    snr_time = [snr_time; end_ts + zeros(excess_tail, 1)];
    msg_1 = sprintf('added %d time stamps at end of SnR state timestamps', ...
        excess_tail);
elseif excess_tail < 0
    snr_time = snr_time(1:n_mdp_states);
    msg_1 = sprintf('removed last %d SnR state timestamps', -excess_tail);
end

log_msg(folder_log, 'snr-state-removal', msg_1);
mdp_states.start_t = snr_time;