function [behavior_table, event_timing_struct] = behavior_parser(filenames, timing_table)
% The code of this function was adapted from behavioral processing of the RIFF_player_nightRIFF.m
% * * AlexKaz, 29/07/19 * *

    [total_struct] = create_table_from_all_csvs(filenames);
    cleaned_beh_cellarr = cell(1, 3);
    snr_t_cellarr = cell(1, 3);
    bhv_idx = timing_table.EventType == 'bhv';
    t_beh_snr = timing_table.Time(bhv_idx);

    for ii = 1:3  % For each of the environmentns, find optimal alignment.
        curr_beh_trigs = total_struct.(['Env' num2str(ii) '_trig_t']);
        
        % ==== OLD APPROACH 24.05.20 - only try to remove one trig from each array (snr or beh)
%         curr_snr_t = t_beh_snr;
%         [curr_clean_beh, t_bhv_bad] = align_beh_snr_trigs(curr_snr_t, curr_beh_trigs);  % Try to align with all SNR trigs
%         [t_bhv2, t_bhv_bad2] = align_beh_snr_trigs(curr_snr_t(2:end), curr_beh_trigs);  % Try to align without first SNR trig
%         [t_bhv3, t_bhv_bad3] = align_beh_snr_trigs(curr_snr_t, curr_beh_trigs(2:end));  % Try to align without first behavior trig
% 
%         dff1 = abs(diff(diff(curr_clean_beh) - diff(curr_snr_t)));
%         dff2 = abs(diff(diff(t_bhv2) - diff(curr_snr_t(2:end))));
%         dff3 = abs(diff(diff(t_bhv3) - diff(curr_snr_t)));
%         [~,ind] = min([max(dff1),max(dff2),max(dff3)]);
%         switch ind
%             case 2
%                 curr_clean_beh = t_bhv2;
%                 t_bhv_bad = t_bhv_bad2;
%                 curr_snr_t = t_beh_snr(2:end);
%             case 3
%                 curr_clean_beh = t_bhv3;
%                 t_bhv_bad = t_bhv_bad3;
%         end
        
        % ==== NEW APPROACH 24.05.20 - try 10 trimming options
        TRIM_TRIGS_AT_EACH_SIZE = 5;
        diff_arr = cell(1, 2*TRIM_TRIGS_AT_EACH_SIZE+1);
        t_bhv_arr = cell(1, 2*TRIM_TRIGS_AT_EACH_SIZE+1);
        t_bhv_bad_arr = cell(1, 2*TRIM_TRIGS_AT_EACH_SIZE+1);
        start_ind_snr = zeros(1, 11);
        start_ind_beh = zeros(1, 11);
        for i = 1:(1+TRIM_TRIGS_AT_EACH_SIZE)
            [t_bhv_arr{i}, t_bhv_bad_arr{i}] = align_beh_snr_trigs(t_beh_snr(i:end), curr_beh_trigs);
            diff_arr{i} = abs(diff(diff(t_bhv_arr{i}) - diff(t_beh_snr(i:end))));
            start_ind_snr(i) = i;
            start_ind_beh(i) = 1;
        end
        for i = 2:(TRIM_TRIGS_AT_EACH_SIZE+1)
            curr_ind = i + TRIM_TRIGS_AT_EACH_SIZE;
            [t_bhv_arr{curr_ind}, t_bhv_bad_arr{curr_ind}] = align_beh_snr_trigs(t_beh_snr, curr_beh_trigs(i:end));
            diff_arr{curr_ind} = abs(diff(diff(t_bhv_arr{curr_ind}) - diff(t_beh_snr)));
            start_ind_snr(curr_ind) = 1;
            start_ind_beh(curr_ind) = i;
        end
        [min_diff_val, ind_new] = min(cell2mat(cellfun(@max, diff_arr, 'UniformOutput', false)));
        THR_GOOD_ALIGNMENT = 0.5;   % Good alignment results in values of [1e-3, 0.3]
        if min_diff_val > THR_GOOD_ALIGNMENT
            disp('=== Denoising of behavioral triggers failed, too large deviations from SNR trigger train ===');
        end
        curr_clean_beh = t_bhv_arr{ind_new};
        t_bhv_bad = t_bhv_bad_arr{ind_new};
        curr_snr_t = t_beh_snr(start_ind_snr(ind_new):end);

        cleaned_beh_cellarr{ii} = curr_clean_beh;
        snr_t_cellarr{ii} = curr_snr_t;
    end
    
    [event_timing_struct] = get_times_for_GUI(total_struct, cleaned_beh_cellarr, ...
                                             snr_t_cellarr);  %TODO 150819: Fix the putative air-puff trigger, as done inside 'reformat_beh_data_into_table'. Affects only the RIFF_player
    behavior_table = reformat_beh_data_into_table(event_timing_struct);

end