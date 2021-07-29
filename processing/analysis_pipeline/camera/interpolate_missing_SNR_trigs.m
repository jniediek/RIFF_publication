function fixed_SNR = interpolate_missing_SNR_trigs(SNR_timings)

    % Function interpolate_missing_SNR_trigs fills in missing triggers in the SNR trigger stream.
    % There can be arbitrary number of missed trigs, including triggers missed in a raw.
    % Assumptions:
    % 1. The SNR triggers are produced at a uniform grid, i.e. 1Hz as camera LEDs
    % 2. The first and the last triggers are not missing.
    % 
    % Inputs:
    %     SNR_timings - (1xN array of ) - Array of SNR trigs, with missing triggers
    % 
    % 
    % Outputs:
    %     fixed_SNR - (1x(N + n_missed_trigs)) - Array of SNR trigs, where missing trigs were filled.
    % 
    % 
    % Usage:
    %     >> fixed_SNR_trigs = interpolate_missing_SNR_trigs(SNR_trigs);

    % === Calculate number of missed triggers - estimation of new array size
    dff = diff(SNR_timings);
    pivot1 = find(dff > 1.5);
    pivot2 = pivot1 + 1;
    missing_trigs = round(sum(SNR_timings(pivot2) - SNR_timings(pivot1)) - 1*length(pivot1));
    fixed_SNR = zeros(1, length(SNR_timings) + missing_trigs);
    
    % === Init counters for the single pass over the SNR array ===
    do_stop = 0;
    ind_orig = 1;
    ind_new = 1;
    
    fixed_SNR(1) = SNR_timings(1);  % I assume that the first trigger is not missing
    fixed_SNR(end) = SNR_timings(end);
    ind_new = ind_new + 1;
    ind_orig = ind_orig + 1;
    GAP_THR = 1.5; % The latency of SNR trigs is 1Hz + noise. I assume inter_trig is < 1.5
    
   % === Single pass over the data and patching holes of arbitrary size with interpolated grid ===
    while ~do_stop
        if dff(ind_orig) < GAP_THR  % The regular case where two consecutive trigs are < 1.5 sec apart. 
            fixed_SNR(ind_new) = SNR_timings(ind_orig);
            ind_new = ind_new + 1;
            ind_orig = ind_orig + 1;
        else  % Case when |next_trig - curr_trig| > 1.5
            pivot1 = SNR_timings(ind_orig);  % Get the trig that preceeds the gap
            pivot2 = SNR_timings(ind_orig+1);  % Get the tfirst trig after the gap
            n_missing = round(pivot2 - pivot1)-1;
            % The two pivot triggers are used as anchors to interpolate the missed trigers in between
            new_sig = interp1([0 (n_missing+1)], [pivot1 pivot2], 0:(n_missing+1), 'spline');
            fixed_SNR(ind_new:(ind_new+n_missing+1)) = new_sig;
            
            ind_new = ind_new + (n_missing+1) + 1;  % Shift the counters by the filled amount
            ind_orig = ind_orig + 2;
            
            disp(['=== Filled ' num2str(n_missing) ' missing triggers in SNR by ' num2str(new_sig) ' ===']);
        end
        
        % Stopping condition - When all the input vector was scanned
        if ind_orig >= length(SNR_timings)
            do_stop = 1;
        end
    end
end