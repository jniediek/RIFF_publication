function process_rat_folder(data_folder, rat_num, job_parts)
% JN 2019-01-27
% function runs one rat folder

expdata = prepare_session_folders(data_folder, rat_num);
% JN 2020-05-11
if height(expdata.rat_table) == 0
    return
end
%Added by AP 240420
out_folder_rat = expdata.folders.out_folder_rat;

% process and save neural data

if job_parts.neural
    switch expdata.neural_mode
        case 'deuteron'

            % JN 2019-07-31
            % the -1 is important here!
            start_fnum = expdata.rat_table.NeuralFilesStart(1) - 1;
            stop_fnum = expdata.rat_table.NeuralFilesStop(end) - 1;

        case 'tbsi'
            start_fnum = expdata.rat_table.SNRFilesStart(1);
            stop_fnum = expdata.rat_table.SNRFilesStop(end);
    end
end


if job_parts.neural
    
    mpx_prefix = sprintf('%02d%02d%02d', ...
        expdata.year - 2000, expdata.month, expdata.day);
    log_msg(out_folder_rat, 'start-save-spikes', ...
        'starting to extract spikes');
    
     if strcmp(expdata.neural_mode, 'deuteron')
         if expdata.has_autolog
             table_events = expdata.table_ttls_autolog;
             log_msg(out_folder_rat, 'use-autolog', 'using TTL events from deuteron autolog');
         elseif expdata.has_table_ttls
             table_events = expdata.table_ttls;
             log_msg(out_folder_rat, 'use-logger-ttls', 'using TTL events from deuteron logger');
         end

            in_folder = expdata.folders.logging;
    else
        table_filestarts = table();
        table_expanded_events = table();
        % in_folder = out_folder_rat;
        date = sprintf('%02d%02d%02d', ...
            expdata.day, expdata.month, expdata.year - 2000);
        if ispc()
            in_folder = fullfile(expdata.folders.base,'Ana','DAT',['DAT',date]);
        else
            in_folder = ['/GoodmanHome/Archive/Ana/DAT/DAT', date]; %AP 030520 - moved most of the files there
        end
    end
    
    if strcmp(expdata.neural_output_type, 'pipeline')
        stats = process_neural_data(in_folder, expdata.folders.out_folder_rat, ...
			expdata.neural_mode, start_fnum:stop_fnum, expdata.table_filestarts, ...
			mpx_prefix);
        
        % simple data quality check
        check_neural_data(out_folder_rat, expdata.neural_mode);
    elseif strcmp(expdata.neural_output_type, 'kilosort2')
        if expdata.experimenter == 'Maciej'
            is_unfiltered = false;
        elseif expdata.experimenter == 'nightRIFF' || strcmp(expdata.neural_mode,'tbsi')
            is_unfiltered = true;
        else
            error('No data about filtering, please add options to pipeline');
        end
        process_neural_data_kilosort2(in_folder, out_folder_rat, expdata.neural_mode, ...
            start_fnum:stop_fnum, expdata.table_filestarts, is_unfiltered, mpx_prefix);
    else
        
    end
	
    log_msg(out_folder_rat, 'stop-save-spikes', ...
        'extracted spikes');
end


%% Loop over the relevant lines in the rat sessions

for i = 1:height(expdata.rat_table)
    expdata = load_session(expdata, i);
    out_folder_session = expdata.folders.out_folder_session;
    
   	if strcmp(expdata.row.SessionType, 'Behavior')
        if ~job_parts.run_behavioral_sessions
            continue
        end
        
    elseif ismember(expdata.row.SessionType, {'BBNFRA', 'BBN+FRA', 'BBN', 'FRA'})
        if ~job_parts.run_passive_sessions
            continue
        end
    end

    if job_parts.create_metadata
        metadata = create_metadata(expdata, expdata.row.BehaviorFileIndex, ...
            expdata.row.MaestroTableNo, expdata.snr_times);
    else
        metadata = load_metadata(out_folder_session, expdata.row.SessionType);
    end
    
    if job_parts.check_metadata
        check_metadata(expdata, metadata)
    end
    
    if strcmp(expdata.row.SessionType, 'Behavior')        
        % camera
        if job_parts.camera
            fname = sprintf('RIFF_s%d_R1_1.tif', expdata.row.CameraFileIndex);
            camera_db = ...
                camera_parser_module_tif_to_mat(expdata.folders.camera, ...
                fname, expdata.snr_times, out_folder_session, expdata.experimenter, ...
                job_parts.camera_with_images);
             % Run camera analysis only if images & LEDs were processed
            if job_parts.camera_with_images
                camera_parser_module_mat_to_pdf(camera_db, out_folder_session);
            end
        end
        
        % behavior
        if job_parts.behavior
            behavior_analysis(metadata.behavior_table, out_folder_session)
            close();
        end
        
        % mdp/maestro
        if job_parts.mdp
            mdp_analysis(metadata.sounds_table, metadata.mdp_table, ...
                expdata.experimenter, out_folder_session);
            close();
        end
        
        %combine
        if job_parts.combine
            combine_behavior_maestro(out_folder_session);
            close();
        end
        
        if job_parts.sounds
            %table_expanded_events = snr_times;
            %t_events = ...
            %    table_expanded_events(row.SNREventsStart:row.SNREventsStop, :);
            behavior_sound_responses(metadata.sounds_table, expdata.folders.out_folder_rat, ...
                out_folder_session)
        end
        
        
    elseif ismember(expdata.row.SessionType, {'BBN', 'FRA', 'BBNFRA', 'BBN+FRA'})
        if job_parts.sounds
            % JN 2019-06-16
            % this is still done without sound alignment
	
            %%t_events = ...
            %    table_expanded_events(row.LoggerEventsStart:row.LoggerEventsStop, :);
            sound_responses(metadata, expdata.folders.out_folder_rat, ...
                out_folder_session)
        end
        
    end
end

if expdata.do_clustering && strcmp(expdata.neural_output_type, 'kilosort2')
    
        process_NA_from_single_experiment_kilosort2(out_folder_rat, true, true, true, expdata.is_new_layout, expdata.neural_mode);
%     catch err
%         disp('=== Data kilosorting failed! ===');
%         disp(err);
%     end
    delete_raw_and_bin_NA_kilosort2(out_folder_rat, expdata.delete_raw_bin);
end