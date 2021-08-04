function [states, t_states] = parse_maestro(rat_dir)

    % Function parse_maestro() reads the mdp_table.mat that is produced by the Maestro.
    % 
    % Inputs:
    %     rat_dir - (str) - Location of the mdp_table.mat, inside the experiment folder
    % 
    % Outputs:
    %     states - (table) - Table of the states
    %     t_states - (1xN matrix) - Time array of SNR timestamps
    %
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    %
    % *    *    Created by AlexKaz 23.08.20

    f_name = 'mdp_table.mat';
    maestro_struct = load(fullfile(rat_dir, f_name));
    disp(['mdp_table: ' fullfile(rat_dir, f_name)]);
    states = maestro_struct.mdp_table;
    t_states = states.start_t';
end