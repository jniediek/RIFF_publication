function [clean_env_t, erased_env_t] = align_beh_snr_trigs(snr_t_orig, beh_t_orig)

    % Function align_beh_snr_trigs aligns the triggers from SNR and behavioral system.
    % The behavioral triggers are derived from a single .csv file, of one of the three environments.
    % 
    % Assumptions:
    % 1. Every SNR trigger creates corresponding BEH trigger
    % 2. There is a clock drift between the systems
    % 3. The first SNR and BEH triggers match
    % 
    % Noise phenotype:
    % 1. There are hundreds of spurious triggers on the behavioral system. Noise size varies between systems
    % 2. First 2 SNR triggers don't align well to the first two behavioral triggers, 'staggering' of the SNR on init
    % 
    % Algorithm overview:
    % 1. Create an array of size |SNR|, where aligned BEH indeces will be filled.
    % 2. Store a pointer to the current SNR trig, and propogate it as new SNR-BEH trigger pair is matched
    % 3. For each SNR, look for the two BEH trigger that come right before and after it, and pick the one with smaller distance.
    % 4. The clock-shift is updated with each new aligned pair.
    % 
    % Inputs:
    %     snr_t_orig - (1xS matrix) - SNR timestamps, |SNR| = N
    %     beh_t_orig - (1xB matrix) - behvioral timestamps, |Behavioral| = B
    % 
    % Outputs:
    %     clean_env_t - (1xB matrix) - Behavioral timestamps, each correspoding to a single SNR trig.
    %     erased_env_t - (1xE matrix) - The noise time-stamps
    % 
    % 
    % Example:
    %     >> [t_bhv, t_bhv_bad] = align_beh_snr_trigs(t_behavior, tbn);
    %     >> [t_bhv, t_bhv_bad] = align_beh_snr_trigs(t_behavior(2:end), tbn); 
    %
    % * * AlexKaz, 29/07/19 * *
    
    beh_t = beh_t_orig - beh_t_orig(1);  % Shift both trigger trains to t=0
    snr_t = snr_t_orig - snr_t_orig(1);
    
    % === Align chunk by chunk ===   
    clean_beh_inds = snr_t*0;           % Init the array that will hold behavioral triggers coupled to each SNR
    clean_beh_inds(1) = 1;              %  Assume that the first SNR and behavioral triggers are true match
    
    curr_snr_ind = 2;                   % Init the pointer to the lastly assigned SNR trigger
    curr_snr_t = snr_t(curr_snr_ind);   % The timestamp of the current SNR index
    
    t_shift = 0;                        % The time lag between the SNR and the behavior. Is changed during the alignment process
    prev_is_taken = 0;                  % Flag - The current SNR has been already asigned to a behavioral trigger.
    
    for i = 2:length(beh_t)                 % Iterate beh. triggers to find first one that is bigger than current SNR trig.
        curr_beh_t = beh_t(i) - t_shift;    % Get the current BEH timestamp
        if curr_beh_t >= curr_snr_t         % If the beh. timestamp exceeds SNR timestamp... 
            dist_from_next = abs(curr_beh_t - curr_snr_t);              % distance of curr SNR and curr BEH
            dist_from_prev = abs(beh_t(i-1) - t_shift - curr_snr_t);    % distance of curr SNR and prev BEH
            if (dist_from_next < dist_from_prev) || prev_is_taken       % Check if prev SNR is assigned, or curr BEH is closer to SNR
                clean_beh_inds(curr_snr_ind) = i;   % Assign curr BEH to curr SNR
                prev_is_taken = 1;  % 
            else
                clean_beh_inds(curr_snr_ind) = i-1;  % Assign prev BEH to curr SNR
            end
            t_shift = -(curr_snr_t - beh_t(clean_beh_inds(curr_snr_ind)));  % Recalc the SNR-BEH shift, based on the current tuple
            
            if curr_snr_ind == length(snr_t)  % If all SNR were assigned - exit
                break;
            end
            curr_snr_ind = curr_snr_ind + 1;
            curr_snr_t = snr_t(curr_snr_ind);
        else
            prev_is_taken = 0;  % If BEH was not assigned to any SNR, reset the flag
        end
    end
    
    if clean_beh_inds(end) == 0  % Corner case when the last SNR was left uncoupled to last BEH
        clean_beh_inds(clean_beh_inds == 0) = i;  % If more than last BEH was unmatched, make false alignment that will be discarded later
    end
    
    all_bad_inds = setdiff(1:length(beh_t), clean_beh_inds);
    clean_env_t = beh_t(clean_beh_inds) + beh_t_orig(1);  % Changed on 10.02.2020 by alexkaz
    erased_env_t = beh_t(all_bad_inds) + beh_t_orig(1);
%     h_f = plot_alignment_stats(erased_env_t, snr_t, clean_env_t);
end