function [event_timing_struct, t_behavior] = load_behavior(rat_dir)

    % Function load_behavior() reads the beh_struct_for_RIFF_player.mat that is produced by the pipeline.
    % 
    % Inputs:
    %     rat_dir - (str) - Location of the beh_struct_for_RIFF_player.mat, inside the experiment folder
    % 
    % Outputs:
    %     event_timing_struct - (struct) - Table of events
    %     t_behavior - (struct) - SNR timestamps of the behavioral events.
    % 
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    % 
    % *    *    Created by AlexKaz 23.08.20

    % Load the behavioral struct that was produced esspecially for the RIFF_player
    event_timing_struct = load(fullfile(rat_dir, 'beh_struct_for_RIFF_player.mat'));
    
    % Load the t_behavior
    beh_table = load(fullfile(rat_dir, 'behavior_table.mat'));
    t_behavior = beh_table.behavior_table.start_t;  %TODO: The beh_table is the corrected DB for the putative airpuff trig, so there is misalignment of one beh
end