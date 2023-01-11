function sound_channel = identify_sound_channel(NA_mat_uint16)

    % Function identify_sound_channel() locates the sound shannel in NA recording (if exists).
    % The sound is identified based on its statistics = higher mean channel value, due non-negative
    % air pressure measurments.
    % 
    % Inputs:
    %     NA_mat_int16 - (NxP matrix, uint16) - Data matrix
    %     
    % Outputs:
    %     sound_channel - (scalar) - Num. of channel with sound recording, -1 if sound not found
    % 
    % *   *   AlexKaz 05/2020

    WIN_SIZE = 100;
    SAMP_RATE = 32000;
    MID_RANGE_UINT16 = 2^15;

    if size(NA_mat_uint16, 2) > size(NA_mat_uint16, 1)  % Make sure the second dim representes the channels
        NA_mat_uint16 = NA_mat_uint16';
    end
    if size(NA_mat_uint16, 2) < SAMP_RATE*WIN_SIZE
        data_segment = double(NA_mat_uint16) - MID_RANGE_UINT16;
    else
        data_segment = double(NA_mat_uint16(end-(SAMP_RATE*WIN_SIZE):end, :)) - MID_RANGE_UINT16;  % Only analyze the first chunk, for speed
    end  
    
    sound_channel = -1;
    data_means = mean(data_segment, 1);  % Get the |channels| mean values. Sound has mush higher mean value
    if entropy(data_means) > eps    % Entropy is 0 for equal mean values, and ~0.1 for 1-hot vector
        [~, sound_channel] = max(data_means);
        valid_channels = setdiff(1:size(data_segment, 2), sound_channel);
%         if (entropy(data_means(valid_channels)) > eps)  % 230620 AlexKaz: This worked well for Maciek. but not for nightRIFF
%             disp('=== Sound channel identification FAILED!');
%             return
%         end
        
        disp(['=== Sound channel found on channel: ' num2str(sound_channel) '. The channel is annulated ===']);
    else
        disp(['=== No sound channel was found in the neural recordings ===']);
        return;
    end
end