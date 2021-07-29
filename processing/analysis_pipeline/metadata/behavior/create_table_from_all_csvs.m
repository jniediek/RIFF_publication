function [total_struct] = create_table_from_all_csvs(file_names)
% Function create_table_from_all_csvs extracts the events from all the .csvs to a single struct.
% It auto-iterates over the three .csv if a single experiment and stores all events in a single
% struct.
% 
% Inputs:
%     dir_name - (directory, str) - Repository directory with the raw behavioral values
%     file_names - (scalar) - File names, i.e. 'ANASTROPHE_INSC_191118_WIRE-new_283.csv'
% 
% Outputs:
%     total_struct - (struct) - Struct that aggregates all the events
% 
% Example:
%     >> [total_struct] = create_table_from_all_csvs(dir_name, file_name)
%
% * * AlexKaz, 29/07/19 * *
 
 
    data_cells = cell(1, 3);
    file_name_cells = cell(1, 3);

    for i = 1:length(file_names)
        file_name_cells{i} = fullfile(file_names{i});
    end

    total_struct = {};

    for i = 1:3
        data_table = readtable(file_name_cells{i});
        inlight_bin = strcmp(data_table.Item_Name, 'inlight #4');
        event_38_bin = data_table.Evnt_ID == 38;
        total_struct.(['Env' num2str(i) '_trig_t']) = data_table.Evnt_Time(event_38_bin & inlight_bin);
        Item_Name_cells = extract_events(data_table);
        data_cells{i} = Item_Name_cells;
    end

    for i = 1:3
        f = fieldnames(data_cells{i});
        for j = 1:length(f)
            curr_f_name = ['Env' num2str(i) '_' f{j}];
            total_struct.(curr_f_name) = data_cells{i}.(f{j});
        end

    end
end