function behavior_table = reformat_beh_data_into_table(beh_struct)

    % ===== hyper params ===
    
    water_ports = 2:2:12;
    event_type_map = {'food', 'water', 'airpuff', 'nosepoke'};  % Used to create categorical vars

    % ===== The final variables of the table ===
    
    start_t_arr = [];       % The timestamp of the onset of the beh event, in SNR time units.
    dur_arr = [];      % Only defined to NP, else 0
    event_type_arr = [];    % One of {1..4}, event_type_map: {(1) food, (2) water, (3) airpuff, (4) nosepoke}
    port_arr = [];          % One of {1..12}
    
    % ==== Iterate over each event type in {food, beam, airpuff}, and concat to the table arrays ===
    
    % 1. Iterate over 'food' arrays, differentiate who is water and who is food
    for curr_port_n = 1:12
        curr_start_t = beh_struct.food_timings{curr_port_n};
        curr_port = curr_start_t*0 + curr_port_n;     % Assign port {i} to all those events
        curr_event_type = curr_start_t*0 + (1 + ismember(curr_port_n, water_ports));  % 1 - food, 2 - water
        curr_dur_arr = curr_start_t*0;
        
        start_t_arr = [start_t_arr; curr_start_t];
        dur_arr = [dur_arr; curr_dur_arr];
        event_type_arr = [event_type_arr; curr_event_type];
        port_arr = [port_arr; curr_port];
    end
    
    % 2. Iterate over 'beam' arrays, calculate the NP length.
    for curr_port_n = 1:12
        curr_t = beh_struct.beam_timings{curr_port_n};
        curr_start_t = curr_t(1:2:end); % The NP is registered twice: Onset and offset 
        curr_stop_t = curr_t(2:2:end);
        curr_port = curr_start_t*0 + curr_port_n;     % Assign port {i} to all those events
        curr_event_type = curr_start_t*0 + 4;
        curr_dur_arr = curr_stop_t - curr_start_t;
        if (min(curr_dur_arr) < 0)  % Sanity check for positive duration times
            error('Negative nose poke duration detected!');
        end
        
        start_t_arr = [start_t_arr; curr_start_t];
        dur_arr = [dur_arr; curr_dur_arr];
        event_type_arr = [event_type_arr; curr_event_type];
        port_arr = [port_arr; curr_port];
    end
    
    % 3. Iterate over 'airpuff' arrays, calculate the NP length.
    for curr_port_n = 1:12
        curr_start_t = beh_struct.airpuff_timings{curr_port_n};
        curr_port = curr_start_t*0 + curr_port_n;     % Assign port {i} to all those events
        curr_event_type = curr_start_t*0 + 3;  % 1 - food, 2 - water
        curr_dur_arr = curr_start_t*0;
        
        start_t_arr = [start_t_arr; curr_start_t];
        dur_arr = [dur_arr; curr_dur_arr];
        event_type_arr = [event_type_arr; curr_event_type];
        port_arr = [port_arr; curr_port];
    end
    
    % ==== Gather the data into a table and sort by time ===
    
    event_type = categorical();        % Init the cat array
    for i = 1:length(event_type_map)
        event_type(event_type_arr == i) = event_type_map(i);
    end    
    event_type = event_type';
    
    start_t = start_t_arr; % Rename vars
    duration = dur_arr;
    port = port_arr;
    T = table(start_t, duration, event_type, port);
    behavior_table = sortrows(T, {'start_t'});
    
    % ==== HEURISTIC - removing first event if it is airpuff - ask Ana why :) ===
    
    if (behavior_table(1, :).event_type == 'airpuff')
        behavior_table(1, :) = [];
    end
    
end
