function [food_fixed, beam_fixed, air_fixed] = intrp_t_to_snr(food_timings, beam_timings, ...
                                                         airpuff_timings, ...
                                                         envs,  snr_t_cellarr)
% function intrp_t_to_snr corrects the times of the all time arrays if foor, airpuff and beams given
% the synchronization sequences env1 and snr_t
%                                                          
% Inputs:
%     food_timings - (12x1 cell array of: F x 1 float) - times of food, for each port
%     beam_timings - (12x1 cell array of: B x 1 float) - times of beams, for each port
%     airpuff_timings - (12x1 cell array of: A x 1 float) - times of AP, for each port
%     env1_t - (N x 1 floats) - times of sync trigs as registered by behavior
%     snr_t - (N x 1 floats) - times of sync trigs as registered by SNR
% 
% Outputs:
%     food_fixed - (12x1 cell array of: F x 1 float) - fixed times of food, for each port
%     beam_fixed - (12x1 cell array of: B x 1 float) - fixed times of beams, for each port
%     air_fixed - (12x1 cell array of: A x 1 float) - fixed times of AP, for each port
%         env1_t = env1_t(1:length(snr_t)); %AK: Add on 28/03/2019 to fix the bug of many extra triggers on the behave
%         env2_t = env2_t(1:length(snr_t));
%         env3_t = env3_t(1:length(snr_t));
%
%* * AlexKaz, 29/07/19 * *
    food_fixed = cell(1, 12);
    beam_fixed = cell(1, 12);
    air_fixed = cell(1, 12);
    for env_ind = 1:3
        for arr_ind = 1:4
            curr_ind = arr_ind + 4*(env_ind-1);
            curr_food = food_timings{curr_ind};
            food_fixed{curr_ind} = interp1(envs{env_ind}, snr_t_cellarr{env_ind}, curr_food,...
                                           'linear', 'extrap');

            curr_beam = beam_timings{curr_ind};
            beam_fixed{curr_ind} = interp1(envs{env_ind}, snr_t_cellarr{env_ind}, curr_beam,...
                                           'linear', 'extrap');

            curr_air = airpuff_timings{curr_ind};
            air_fixed{curr_ind} = interp1(envs{env_ind}, snr_t_cellarr{env_ind}, curr_air,...
                                          'linear', 'extrap');
        end
    end
end