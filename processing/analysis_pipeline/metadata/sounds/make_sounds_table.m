function metadata = make_sounds_table(snr_times, maestro_file, expdata)

out_folder = expdata.folders.out_folder_session;
sounds_table = maestro_file.MetaData.sounds;

% this is to fix GitHub Issue #35:
if ismember('Var1', sounds_table.Properties.VariableNames)
    sounds_table.Properties.VariableNames{'Var1'} = 'soundname';
end
            
% These variables are not needed later
rm_vars = {'samp_rate', 'ramp', 'played'};
sounds_table = removevars(sounds_table, rm_vars);
ts_snr = snr_times.Time(snr_times.EventType == 'snd');

metadata = struct();

if height(sounds_table)
    param_file = maestro_file.MetaData.paramFile;
    
    for i = 1:height(param_file)
        fn = param_file.filename{i};
        si = strfind(fn, '\');
        soundname = categorical({fn(si(end)+1:end-4)});
        locs = find(sounds_table.paramline == i);
        if ~isempty(locs)
            soundname = repmat(soundname, length(locs), 1);
            sounds_table.soundname(locs) = soundname;
        end
    end
end

if isfield(maestro_file, 'MDPData')
    
    log_msg(out_folder, 'start-snd-align', ...
        'Starting alignment of sound events')
    
    % JN 2020-05-21
    % It turned out that Maciek's sessions starting October 2019 need a different
    % method here
    
    if ((expdata.experimenter == "Maciej") && ...
       (expdata.year == 2019) && ...
       (expdata.month >= 10))
        start_t = align_sound_times_mdp_maciej_second_batch(ts_snr, ...
            maestro_file);
        stats = struct();
    else
        if expdata.experimenter == "Maciej"
            ttrig_shift = 0;
        elseif expdata.experimenter == "nightRIFF"
            ttrig_shift = -1;
        end
        [start_t, stats] = align_sound_times_mdp(ts_snr, maestro_file, ...
            ttrig_shift); 
    end
    
    sounds_table.start_t = start_t;

    log_msg(out_folder, 'end-snd-align', 'Finished alignment of sound events');
        
else
    % we are processing sounds related to a passive listening session
    tfields = {'paramF', 'paramBBN'};
    
    if size(ts_snr, 1) == height(sounds_table)
        sounds_table.start_t = ts_snr;
        % AP, 050721
    elseif sum(maestro_file.MetaData.sounds.Var1 == 'VaniSounds') % patch to be able to run through passive Vani Sounds presentations
        strig = sounds_table.strig(2251:2261)-sounds_table.strig(2251);
        ts_snr_vani = ts_snr(2251:end)-ts_snr(2251);
        idx = []; 
        for ii = 1:length(strig) 
            if find(abs(strig(ii) - ts_snr_vani) < 1) 
                idx = [idx; find(abs(strig(ii) - ts_snr_vani) < 1)]; 
            end
        end
        sounds_table.start_t = ts_snr([(1:2250)';2250+(idx)]);
    else
        sounds_table.start_t = [ts_snr(1)-0.5; ts_snr];
        keyboard
    end

    for i = 1:2
        tfield = tfields{i};
        if isfield(maestro_file.MetaData, tfield)
            metadata.(tfield) = maestro_file.MetaData.(tfield);
        end
    end
    stats = struct();
end

if height(sounds_table)
    fname = fullfile(out_folder, 'sounds_table.mat');
    save(fname, 'sounds_table');
    log_msg(out_folder, 'save-mat', fname);
    metadata.sounds_table = sounds_table;
    
    fname = fullfile(out_folder, 'ts_fix_sounds_table.mat');
    save(fname, 'stats');
    log_msg(out_folder, 'save-mat', fname);
end

