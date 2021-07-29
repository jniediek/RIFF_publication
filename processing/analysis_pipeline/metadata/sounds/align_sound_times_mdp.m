function [start_t, all_stats] = align_sound_times_mdp(ts_snr, maestro_file, ttrig_shift)
% JN 2019-06-03
% JN 2020-04-26 refactoring
% JN 2020-05-24 adding ttrig_shift

sounds_table = maestro_file.MetaData.sounds;
mdp_states = maestro_file.MDPData.MDPStates;
rat_states = maestro_file.MDPData.ratStates;

idx_ttrig = find([0; diff(mdp_states.ttrig) > 1e-5]);

idx_sounds_0 = sounds_table.bline == 0;
rel_bline_start = find(sounds_table.bline, 1, 'first');

mdp_idx = find([0; diff(rat_states.sline)] & ...
    (rat_states.sline >= rel_bline_start));

rel_bline = sounds_table.bline(~idx_sounds_0);

assert(all(rel_bline == mdp_idx));
assert(all(rel_bline == idx_ttrig + ttrig_shift));

types = unique(mdp_states.type(rel_bline));
n_types = length(types);
type_idxs = cell(n_types, 1);

% JN 2020-05-24 this should reflect the different meaning of ttrig in
% nightRIFF versus Maciej, see GitHub issue #53.
ts_mdp = mdp_states.ttrig(idx_ttrig);

for i = 1:n_types
    nt = sum(mdp_states.type(rel_bline) == types(i));
    fprintf('%s %d\n', types(i), nt);
    type_idxs{i} = mdp_states.type(rel_bline) == types(i);
    
end

n_param = 8;
rows = n_param * n_param * n_types;

stats = zeros(rows, 4);
type_arr = categorical(zeros(rows, 1));

c = 1;
for start_t1 = 1:n_param
    for start_t2 = 1:n_param
        
        % this means that SnR starts at start_t1 and
        %              ts_mdp starts at start_t2
        x_snr = [ts_snr(start_t1) + zeros(start_t2 - 1, 1); ts_snr(start_t1:end)];
        
        for i = 1:n_types
            
            type_idx = type_idxs{i};
            n = sum(type_idx);
            mlen = min([length(x_snr) length(ts_mdp)]);
            if length(type_idx) > mlen
                type_idx = type_idx(1:mlen);
            end
            
            tx_snr = x_snr(type_idx);
            tx_mdp = ts_mdp(type_idx);
            
            stat = diff(tx_snr) - diff(tx_mdp);
            stat = stat * 1000;
            outlier = sum(abs(stat) > 50);
            
            stats(c, 1:4) = [start_t1 start_t2 n outlier];
            type_arr(c) = types(i);
            
            c = c + 1;
        end
        
    end
end

stats = array2table(stats, 'VariableNames', ...
    {'start_t1', 'start_t2', 'n_events', 'outliers'});
stats.type = type_arr;
stats_sum = zeros(n_param^2, 4);

c = 1;
for i = 1:n_param
    for j = 1:n_param
        idx = (stats.start_t1 == i) & (stats.start_t2 == j);
        total_n = sum(stats.n_events(idx));
        total_out = sum(stats.outliers(idx));
        stats_sum(c, 1:3) = [i j total_out/total_n];
        c = c + 1;
    end
end



stats_sum = array2table(stats_sum, 'VariableNames', ...
    {'start_t1', 'start_t2', 'outlier', 'chosen'});

[~, idx] = min(stats_sum.outlier);
stats_sum.chosen(idx) = true;

all_stats.stats = stats;
all_stats.stats_sum = stats_sum;

start_t1 = stats_sum.start_t1(idx);
start_t2 = stats_sum.start_t2(idx);


start_t = [ts_snr(start_t1) + zeros(start_t2 - 1, 1); ...
    ts_snr(start_t1:end)];


n_snd = height(sounds_table);
start_t_frame = zeros(n_snd, 1);


if any(idx_sounds_0)
    start_t_frame(~idx_sounds_0) = start_t;
    start_t = start_t_frame;
else
    
    n_ts = length(start_t);
    tdiff = n_snd - n_ts;
    if tdiff > 0
        start_t = [start_t; start_t(end) + zeros(tdiff, 1)];
    elseif n_ts > n_snd
        start_t = start_t(1:n_snd);
    end
end
