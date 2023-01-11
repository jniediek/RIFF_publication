function process_dt2_list_kilosort2(in_folder, filenums, starttimes, params, out_folder, is_unfiltered)
    
    % Function process_dt2_list_kilosort2 reads a sequence of raw neural data files and aggregate
    % the results into a single data matrix. This matrix is then saved to disk.
    % The data is in uint16 format and is not rescaled to uV units.
    % 
    % Created: 11/02/2020  AlexKaz
    % Edited: 05/11/2020 Ana, turned IS_UNFILTERED into an input variable

    n_channels = numel(params.relevant_channels);

    n_files = length(filenums);
    [~, locb] = ismember(filenums, starttimes.File_num);
    starttimes_snr = starttimes.snr_times(locb);
    starttimes = starttimes.Time_ms_Logger(locb);

    if n_files ~= length(starttimes)
        error('Recieved %d file numbers and %d starttimes', n_files, ...
            length(starttimes))
    end

    default_size = 2^18;  % = 262144
    data = zeros(n_files * default_size, n_channels, 'uint16');

    block_start = 1;

    for i = 1:n_files
        fnum = filenums(i);
        fname = fullfile(in_folder, sprintf('NEUR%04d.DT2', fnum));

        data_one_file = dt2_read_kilosort2(fname, n_channels);

        this_stop = block_start + default_size - 1;
        data(block_start:this_stop, :) = data_one_file(:, params.relevant_channels);
        block_start = block_start + default_size;
        
    end
    
    IS_UNFILTERED = is_unfiltered;
    
    if IS_UNFILTERED
        % AK 07.2020: Adding support to unfiltered data (nightRIFF)
        data = double(data) - 2^15;
        
        % === Check sound channel by mean values ===
        data_means = mean(data);
        [max_val, max_ind] = max(data_means);
        SOUND_MEAN_THR = 1000;  % assumption: Mean should be > 1000
        if (max_val > SOUND_MEAN_THR)
            sound_ch = max_ind;
            sound_data = data(:, sound_ch);
        else
            sound_ch = -1;
        end
        
        n_channels = size(data, 2);
        
        if strcmp(getenv('COMPUTERNAME'), 'DANCE')
            batch_size = 4;
        elseif strcmp(getenv('COMPUTERNAME'), 'HISTORY')
            batch_size = 2;
        else
            batch_size = 2;
        end
        
        Fs_sig = 32000;
        f1 = 300;
        f2 = 10000;
        b = fir1(f1*3, [f1 f2]/Fs_sig*2);   % The filter width (argumen No.1 was not optimized!)
        for i = 1:batch_size:n_channels
            curr_channels = (i-1)+(1:batch_size);
            data(:, curr_channels) = gather(flipud(filter(b, 1, flipud(filter(b, 1, gpuArray(data(:, curr_channels)))))));
        end
        
        if sound_ch > 0
            data(:, sound_ch) = sound_data;
        end
        data = uint16(data + 2^15);  % Comply with Maciek processing
    end
    
    % === Store the file to disk ===
    BitResolution = params.BitResolution;
    t_fname = fullfile(out_folder, ['raw_' num2str(filenums(1)) '_' num2str(filenums(end)) '.mat']);
    save(t_fname, 'data', 'starttimes_snr', 'starttimes', 'BitResolution', '-v7.3', '-nocompression');
%     save(t_fname, 'data', 'starttimes_snr', 'starttimes', 'BitResolution');
    % With compression the file is 260MB and is saved on network in 14 sec, no compression is 400GB and takes 6
end