function sound_table = load_sound_table(rat_dir)

    % Function load_sound_table() reads the sounds_table.mat that is produced by the pipeline.
    % 
    % Inputs:
    %     rat_dir - (str) - Location of the sounds_table.mat, inside the experiment folder
    % 
    % Outputs:
    %     sound_table - (struct) - Table of sounds
    % 
    % ==> Externalized from RIFF_player_nightRIFF on 23.08.20 by alexkaz
    % 
    % *    *    Created by AlexKaz 23.08.20
    
    db = load(fullfile(rat_dir, 'sounds_table.mat'));
    disp(['Sound table: ' fullfile(rat_dir, 'sounds_table.mat')]);
    sound_table = db.sounds_table;
    sound_table(sound_table.start_t == 0, :) = [];  % Remove the control sounds at the beginning, remove 'silence' sound type
end