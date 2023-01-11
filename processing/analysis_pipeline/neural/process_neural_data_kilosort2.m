function process_neural_data_kilosort2(in_folder, out_folder, mode, fnums, ...
    table_filestarts, is_unfiltered, mpx_prefix)

params = struct();


switch mode
    case 'deuteron'
        params.relevant_channels = 1:32;
        files_per_run = 50;
        params.KHz_Orig = 32;
        params.KHz = 32;
        params.Gain = 1;
        params.BitResolution = 0.195;
        params.decimate_factor = 32;
        log_msg(out_folder, 'KHz', num2str(params.KHz));
        log_msg(out_folder, 'BitResolution', ...
            sprintf('%.6f', params.BitResolution));
    case 'tbsi'
%         h = msgbox('Kilosort2 is not yet implemented for tbsi system!');
%         error('Kilosort2 doesn`t support tbsi');
        params.relevant_channels = [1:4,6:32];
        params.do_delete_chan_files = false; %make variable in next versions, after checkup, should be able to delete those files
        files_per_run = 1;        
    otherwise
        error('mode %s is unknown', mode)
end
params.mode = mode;

fstarts = 1:files_per_run:length(fnums);

% ADD PARFOR HERE
tic;
% for i_fnum = 1:length(fstarts)
switch mode
    case 'deuteron'
        parfor i_fnum = 1:length(fstarts)
            start = fstarts(i_fnum);
            stop = min(start + files_per_run - 1, length(fnums));
            process_dt2_list_kilosort2(in_folder, fnums(start:stop), table_filestarts, params, out_folder, is_unfiltered);
        end
    case 'tbsi' % AP 181120
        % get all data into 31 files, one for each channel
%         for i_fnum = 1:length(fstarts)
%             start = fstarts(i_fnum);
%             process_mpxmat_file_kilosort2(in_folder, out_folder, mpx_prefix, start, params);
%         end
        reshape_mpxmat_files_kilosort2(out_folder,params.relevant_channels,params.do_delete_chan_files)
        
end
runtime = toc();
disp(['=== NA finished and stored to ' out_folder ' in ' num2str(round(runtime, 1)) ' seconds ===']);
% When stored to Y:\ NET, 9.6min for compressed data, 9.4 for uncompressed. Speed is unaffected, so lets go with reduced size!
% When stored to F:\ SSD, 
end