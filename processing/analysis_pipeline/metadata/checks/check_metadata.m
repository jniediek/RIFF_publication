function check_metadata(expdata, metadata)
% JN 2019-07-09
% JN 2020-04-07
% JN 2020-04-30

title_str = sprintf('%s %04d-%02d-%02d %s', expdata.experimenter, ...
    expdata.year, expdata.month, expdata.day, ...
    expdata.folders.out_folder_session);


fig = figure('Position', [0 0 1400 1000], 'Visible', 'on');
annotation('textbox', [.05 .9 .4 .05], 'String', title_str, ...
    'interpreter', 'none', 'edgecolor', 'none');

if isfield(metadata, 'mdp_table')
    mdp_table = metadata.mdp_table;
    fname_stats = fullfile(expdata.folders.out_folder_session, ...
        'ts_fix_mdp_table.mat');
    S = load(fname_stats);
    stats = S.ts_stats;
    check_mdp_timing(mdp_table, stats, fig)
end

if isfield(metadata, 'sounds_table')
    sounds_table = metadata.sounds_table;
    
    if isfield(metadata, 'mdp_table')
        fname_stats = fullfile(expdata.folders.out_folder_session, ...
            'ts_fix_sounds_table.mat');
        S = load(fname_stats);
        stats = S.stats;
        check_mdp_sound_timing(mdp_table, sounds_table, stats, ...
            expdata.experimenter, fig)
    else
        check_sound_timing(sounds_table, fig)
    end
end

fname = fullfile(expdata.folders.out_folder_session, 'ts_fix.png');
print(fig, fname, '-dpng', '-r300');
