function ttl_times = DT_get_ttls_from_logger_table(table_events, result_folder)

% JN 2018-12-20
% function extracts all TTL values and times

idx1 = table_events.EventType == 'Digital in';
idx2 = contains(table_events.Details, 'Digital input port status');
mode = 'status';

% JN 2018-12-30
% test whether we are working with a CSV file that reports the status or
% with a CSV file that reports rising and falling events

if ~any(idx2)
    log_msg(result_folder, 'ttl-mode', ...
        'No input port status changes detected, switching to rising/falling mode');
    mode = "risefall";
    idx2 = contains(table_events.Details, 'edge on pin number');
end
    
idx = idx1 & idx2;
n_rows = sum(idx);
direction = cell(n_rows, 1);

if mode == "status"
    tfun = @(line) (hex2dec(line(31:end)));
    % for debugging:
    % tfun = @(line) (fprintf('%s\n', line(31:end)));
    ttls = cellfun(tfun, table_events.Details(idx));

elseif mode == "risefall"
    % we assign numbers 1 and 3 to rising and falling here
    idx_rise = contains(table_events.Details(idx), 'rising');
    idx_fall = contains(table_events.Details(idx), 'falling');
    ttls = zeros(sum(idx), 1, 'int32');
    ttls(idx_rise) = 1;
    ttls(idx_fall) = 3;
    direction(idx_rise) = {'rising'};
    direction(idx_fall) = {'falling'};
end

ttl_times = table(ttls, table_events.Time_ms(idx), ...
    categorical(direction), ...
    'VariableNames', {'TTL', 'Time_ms', 'Direction'});