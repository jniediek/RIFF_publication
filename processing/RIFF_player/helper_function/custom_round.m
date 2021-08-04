function [pivot_vals, pivot_inds] = custom_round(pivots, arr, is_round)

% Function custom_round floors (or rounds) one array to the custom values of the other.
% Assumption: The arrays are sorted. Default: floor to lower pivot
% 
% Inputs:
%     pivots  - (1xN array) - Array of pivot values that define the rounding grid
%     arr     - (1xM array) - Array of values to be projected on the grids
%     is_round- (flag) - When true, apply ROUND (|1 --  2.2 ->- 3|). Default: FLOOR (|1 -<-  2.2 -- 3|)
%  
% Outputs:
% 	pivot_vals - (1xM array) - Pivot values that correspond to each value from arr
%     pivot_inds - (1xM array) - Pivot indices that correspond to each value from arr
% 
% Example:
%     >> [vals, inds] = custom_round([3 4 5], [0 3.5 4 6]); % Vals=[3,3,4,5],inds=[1,1,2,3]

    if nargin == 2
        is_round = false;
    end
    [arr, orig_inds] = sort(arr, 'ascend');
    pivot_inds = arr*0 + length(pivots);
    
    if ~is_round  % The O(n) version of the floor - single pass through the array
        arr_1_len = length(pivots);
        arr_2_len = length(arr);
        curr_arr1_ind = 1;
        curr_arr2_ind = 1;

        while (curr_arr2_ind <= arr_2_len) && (curr_arr1_ind <= arr_1_len)
            if (arr(curr_arr2_ind) < pivots(curr_arr1_ind))
                pivot_inds(curr_arr2_ind) = max(1, curr_arr1_ind-1);
                curr_arr2_ind = curr_arr2_ind + 1;
            else
                curr_arr1_ind = curr_arr1_ind + 1;
            end
        end
    else
        pivot_inds = pivot_inds*0 + 1;
        watershed_bins = [pivots(1) diff(pivots)/2 + pivots(1:end-1) pivots(end)];
        for i = 2:length(watershed_bins)
            % For each watershed bin, find arr values that fit in
            curr_inds = (arr > watershed_bins(i-1)) & (arr <= watershed_bins(i));
            pivot_inds(curr_inds) = i-1;
        end
        % Deal with arr vals that are outside the bins
        pivot_inds(arr >= pivots(end)) = length(pivots);
        pivot_inds(arr <= pivots(1)) = 1;
    end
    
    pivot_vals = pivots(pivot_inds);
    
    % === Restore the original values order, for unsorted arrays ===
    pivot_vals(orig_inds) = pivot_vals;
    pivot_inds(orig_inds) = pivot_inds;
end