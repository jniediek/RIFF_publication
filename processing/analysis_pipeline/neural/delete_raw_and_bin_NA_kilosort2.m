function delete_raw_and_bin_NA_kilosort2(output_dir, do_delete_NA_raw_files)

    % Delete temporal files - Cleaning the data after the run
    
    ks_output_dir = fullfile(output_dir, 'ks_output');
    if do_delete_NA_raw_files
        try
            delete(fullfile(output_dir, 'raw_*'));
            delete(fullfile(ks_output_dir, 'temp_wh.dat'));
            delete(fullfile(ks_output_dir, 'NA_large.bin'));
        catch
            % Wrapped in try/catch for warning supression when files are not found
        end
    end
end