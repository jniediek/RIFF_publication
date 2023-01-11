function [TTL, CD] = DT_parse_deutoron_autologs(folder)

% JN 2020-04-15
files = dir(fullfile(folder, 'AutoLOG_*.txt'));

% JN 2020-05-08
if isempty(files)
    error("No deuteron AutoLOG files found in %s", folder)
end

n_files = length(files);

all_ttl_tables = cell(n_files, 1);
all_cd_tables = cell(n_files, 1);


for i_file = 1:n_files
    fname = fullfile(folder, files(i_file).name);
    
    opts = detectImportOptions(fname);
    opts.VariableNames = {'pc_time', 'pc_timestamp', 'message'};
    
    t = readtable(fname, opts);
    if ~isempty(t) %AP 280420
        % get the TTLs
        digital_idx = find(contains(t.message, 'Digital input'));
        if ~isempty(digital_idx) %AP 240620
            n_trig = length(digital_idx);
            result = zeros(n_trig, 10);
            
            for i_row = 1:n_trig
                idx = digital_idx(i_row);
                result(i_row, 1) = i_file;
                result(i_row, 2) = idx;
                result(i_row, 3) = t.pc_timestamp(idx);
                
                A = sscanf(t.message{idx}, ...
                    'RatLog-64 SN %d: t=%02d:%02d:%f Digital input ch=%d state=%d');
                result(i_row, 4) = (A(2)*3600 + A(3)*60 + A(4))*1000;
                result(i_row, 5:end) = A;
            end
            
            ttl_result = array2table(result, 'VariableNames', ...
                {'Src_File_Idx', 'File_Line', 'PC_Time', 'Transceiver_Time', ...
                'Logger_SN', 'Hour', 'Minute', 'Second', 'Channel', 'State'});
            
            all_ttl_tables{i_file} = ttl_result;
            
            % get the time difference readings
            cd_idx = find(contains(t.message, 'CD='));
            n_cd = length(cd_idx);
            result = zeros(n_cd, 6);
            
            for i_row = 1:n_cd
                
                idx = cd_idx(i_row);
                
                result(i_row, 1) = i_file;
                result(i_row, 2) = idx;
                this_pc_time = t.pc_timestamp(idx);
                result(i_row, 3) = this_pc_time;
                
                pre = find(ttl_result.PC_Time <= this_pc_time, 1, 'last');
                post = find(ttl_result.PC_Time >= this_pc_time, 1, 'first');
                
                if numel(pre)
                    result(i_row, 4) = ttl_result.PC_Time(pre);
                    result(i_row, 5) = ttl_result.Transceiver_Time(pre);
                    use_pre_element = true;
                else
                    result(i_row, 4:5) = [nan, nan];
                    use_pre_element = false;
                end
                
                if numel(post)
                    result(i_row, 6) = ttl_result.PC_Time(post);
                    result(i_row, 7) = ttl_result.Transceiver_Time(post);
                    use_post_element = true;
                else
                    result(i_row, 6:7) = [nan, nan];
                    use_post_element = false;
                end
                
                if use_pre_element
                    dt = this_pc_time - result(i_row, 4);
                    mytime = result(i_row, 5) + dt;
                elseif use_post_element
                    dt = result(i_row, 6) - this_pc_time;
                    mytime = result(i_row, 7) - dt;
                else
                    mytime = nan;
                end
                
                result(i_row, 8) = mytime;
                
                str_idx = strfind(t.message{idx}, 'CD');
                
                res = sscanf(t.message{idx}((str_idx+3):end), '%f %s');
                result(i_row, 9) = res(1) * 1000;  % convert to milliseconds for late use
                
            end
            
            cd_result = array2table(result, 'VariableNames', ...
                {'Src_File_Idx', 'File_Line', 'PC_Time', 'Pre_PC_Time', ...
                'Pre_Transceiver_Time', 'Post_PC_Time', ...
                'Post_Transceiver_Time', 'Transceiver_Time', 'CD_ms'});

            % AP 030720: remove outliers from CD table
            md = median(cd_result.CD_ms);
            rows_to_remove = find(abs(cd_result.CD_ms) > abs(md*100));
            cd_result(rows_to_remove,:) = [];
            % ---------
            all_cd_tables{i_file} = cd_result;
        end
    end
end

TTL = vertcat(all_ttl_tables{:});
CD = vertcat(all_cd_tables{:});