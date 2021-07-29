function [Item_Name_struct] = extract_events(data_table)
% Function extract_events gets a single table with parsed event data from a single .csv, and converts
% it to a struct. the keys of the struct are the names of the events.
% 
% Inputs:
%     data_table - (N x 8 table) - Each column holds a single event type
% 
% Outputs:
%     Item_Name_struct - (struct) - stores the event types as the keys.
% 
% Example:
%     >> [Item_Name_struct] = extract_events(data_table);
%
% * * AlexKaz, 29/07/19 * *

    % Extract the timings
    Evnt_Time = data_table.Evnt_Time;

    % Extract the names of the events
    Item_Name = data_table.Item_Name;
    Item_Name = Item_Name(1:(end-3));  % Remove the last 3 lines (SYSTEM)
    Item_Name_types = sort(unique(Item_Name));
    Item_Name_cell = cellstr(Item_Name);
    Item_Name_struct = struct();
    for i = 1:length(Item_Name_types)
        curr_name = char(Item_Name_types(i));   % Convert from string to char array
        valid_map_key_name = strrep(curr_name, ' ', '_');
        valid_map_key_name = strrep(valid_map_key_name, '#', '_');
        valid_map_key_name = strrep(valid_map_key_name, '(', '');  % Remove illigal start of words
        valid_map_key_name = strrep(valid_map_key_name, ')', '');  % Remove illigal ends of words
        valid_map_key_name = strrep(valid_map_key_name, '_S', 'S');  % Remove illigal start of words
        valid_map_key_name = strrep(valid_map_key_name, '_T', 'T');  % Remove illigal start of words
        binary_vector = strcmp(Item_Name_cell, curr_name);
        counter = sum(binary_vector);
        Item_Name_struct.(valid_map_key_name) = struct('binary_vector', binary_vector, ...
                                              'counter',      counter, ...
                                              'times',        Evnt_Time(binary_vector));
    end
end
