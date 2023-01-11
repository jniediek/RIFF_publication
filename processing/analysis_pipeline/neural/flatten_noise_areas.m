function [data_mat, noise_locs] = flatten_noise_areas(data_mat, is_uV, neural_mode, bit_resolution)
    
% changes by AP, 061220, adding options for both deuteron and tbsi

    if strcmp(neural_mode, 'deuteron')
        SAMP_RATE = 32000;
    elseif strcmp(neural_mode, 'tbsi')
        SAMP_RATE = 22000;
    end
    NOISE_THR = 300;   % In uV. Normal spike is ~70 uV, large is 200 uV
    NOISE_WIDTH = 5*(SAMP_RATE/1000);
    STD_HEIGHT = 50;
    
    if ~is_uV
        TO_uV_FACT = bit_resolution; %0.195;
        NOISE_THR = NOISE_THR / TO_uV_FACT;
        STD_HEIGHT = STD_HEIGHT/ TO_uV_FACT;
        disp('>>> Data is not scaled to uV, adjusting thr in whitening! <<<');
    end
    window = 1 - create_window(NOISE_WIDTH*2+1, 2*(SAMP_RATE/1000), 2*(SAMP_RATE/1000));
    
    abs_trace = max(abs(data_mat), [], 2);
    std_trace = std(data_mat, [], 2);
    [~, noise_locs] = findpeaks(std_trace, 'MinPeakHeight', STD_HEIGHT,...
                                           'MinPeakDistance', NOISE_WIDTH,...
                                           'WidthReference', 'halfheight');
    disp(['Found ' num2str(length(noise_locs)) ' regions with high variance']);
    %%% == Plot first few seconds of the raw traces + var line + var thr crossings
%     figure; plot(int16(data_mat(1:1e5, :) + (1:32)*400));
%     hold on;
%     plot(int16(var_trace(1:1e5) - 1000), 'k');
%     plot(noise_locs(noise_locs < 1e5), noise_locs(noise_locs < 1e5)*0 - 1000, 'r.', 'markersize', 20);
    % Manually mark beginning and end for removal
    
    if (max(abs_trace(1:NOISE_WIDTH+1) > NOISE_THR))
        noise_locs = [1; noise_locs];
    end
    if (max(abs_trace(end-NOISE_WIDTH:end) > NOISE_THR))
        noise_locs = [noise_locs; length(abs_trace)];
    end
    
    % Remove the marked dots from the data array
    
    for i = 1:length(noise_locs)
        curr_loc = noise_locs(i);
        curr_loc = min(size(data_mat, 1)-NOISE_WIDTH, max(NOISE_WIDTH+1, curr_loc));
        
        data_mat((-NOISE_WIDTH:NOISE_WIDTH) + curr_loc, :) = data_mat((-NOISE_WIDTH:NOISE_WIDTH) + ...
                                                                     curr_loc, :) .* window';
        if (curr_loc == NOISE_WIDTH+1)  % Annulate sig start if noise happened at the beggining, fixes pre-filt artifacts
            data_mat(1:NOISE_WIDTH, :) = 0;
        end
        if(curr_loc == (size(data_mat, 1)-NOISE_WIDTH))  % Symmetrical to previous condition
            data_mat(end-NOISE_WIDTH:end, :) = 0;
        end
    end
end

function window = create_window(len, onset1, onset2)
% function CREATE_WINDOW creates a window that can be used for FFT.
%
% Usage:
%      >> create_window(1000, 100, 200)
%
% Parameters:
%     (1) len     - Length of the window to be created
%     (2) onset1  - limit where the ramp up finished and reaches 1
%     (3) onset2  - Length of ramp down, taht is placed at the end of the window.
%
% Updates:
%   - 26/10/17 - create_window doen't crash when provided floats/double. It
%   prints warning message
%
    if((nargin < 3) || (len < 1) || (onset1 < 1) || (onset2 < 1) || (onset1+onset2 >= len))
        disp('The function was wrongly used, please read HELP');
        help create_window;
        return;
    end
    
    % Deal with non-integer (double, float) input
    if((round(len) ~= len) ||(round(onset1) ~= onset1) ||(round(onset2) ~= onset2))
        disp('WARNING! create_window() had to round the provided non-integer values');
        len = round(len);
        onset1 = round(onset1);
        onset2 = round(onset2);
    end
    window = ones(1, len);
    
    up = (0:onset1-1) / onset1;
    window(1:onset1) = up;
    
    down = fliplr((0:onset2-1) / onset2);
    window((len-onset2+1):end) = down;
end