function [event_timing_struct] = get_times_for_GUI(all_behave_struct, beh_trigs_cellarr,...
                                                  snr_t_cellarr)
% Function get_times_for_GUI generates arrays of timings (enclosed into cell arrays) with timings
% fixed for SNR times.
% 
% Inputs:
%     all_behave_struct - (struct) - Struct of all behavioral arrays as outputted by the parsing
%                                    function
%     env1              - (N x 1) - Times of sync trigs as registered by the behavior system
%     snr_t             - (N x 1) - Times of sync trigs as registered by the SNR
% 
% Outputs:
%     event_timig_struct - () - 
% 
% * * AlexKaz, 29/07/19 * *

    food_timings = cell(1, 12);
    beam_timings = cell(1, 12);
    airpuff_timings = cell(1, 12);

    for env_ind = 1:3
        curr_env_name = ['Env' num2str(env_ind) '_'];
        for port_ind = 1:4
            food_name = [curr_env_name 'food__' num2str(port_ind)];

            if (strcmp(food_name(end-6:end), 'food__2')) % Env#_food__2 is actually -> Env#_water__1
                food_name = [food_name(1:end-7) 'water__1'];
            end
            if (strcmp(food_name(end-6:end), 'food__3'))% Env#_food__3 don't exist -> Env#_food__2
                food_name = [food_name(1:end-7) 'food__2'];
            end
            if (strcmp(food_name(end-6:end), 'food__4'))% Env#_food__4 don't exist -> Env#_water__2
                food_name = [food_name(1:end-7) 'water__2'];
            end

            beam_name = [curr_env_name 'beam__' num2str(port_ind)];
            airpuff_name = [curr_env_name 'airpuff__' num2str(port_ind)];

            if isfield(all_behave_struct, food_name)
                food_timings{port_ind + 4*(env_ind - 1)} = all_behave_struct.(food_name).times;
            end

            if isfield(all_behave_struct, beam_name)
                beam_timings{port_ind + 4*(env_ind - 1)} = all_behave_struct.(beam_name).times;
            end

            if isfield(all_behave_struct, airpuff_name)
                airpuff_timings{port_ind + 4*(env_ind - 1)} = all_behave_struct.(airpuff_name).times;
            end
        end
    end

    [food_fixed, beam_fixed, air_fixed] = intrp_t_to_snr(food_timings, beam_timings, ...
                                                         airpuff_timings, beh_trigs_cellarr,...
                                                         snr_t_cellarr);

    event_timing_struct = struct('food_timings', {food_fixed}, 'beam_timings', {beam_fixed}, ...
                                'airpuff_timings', {air_fixed});
end