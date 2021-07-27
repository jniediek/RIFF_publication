function lgd = plot_short_time_wrapper(t_axes, pinfo, param, zones)


fname = sprintf('metadata_%04d-%02d-%02d_rat-%02d', pinfo.Year, ...
    pinfo.Month, pinfo.Day, pinfo.Rat);

S = load(fullfile('..', 'data', fname));

metadata = S.metadata;

[loc, trial] = get_defined_data(pinfo.Year, pinfo.Month, ...
    pinfo.Day, pinfo.Rat);


start_t = loc.Time(1) + pinfo.StartMinute * 60;

loc_idx = (loc.Time >= start_t) & ...
    (loc.Time <= start_t + param.duration);
loc = loc(loc_idx, :);
tr_idx = (trial.t_att >= start_t) & ...
    (trial.t_fdb <= start_t + param.duration);
trial = trial(tr_idx, :);

poke_idx = (metadata.behavior_table.start_t >= start_t) & ...
    (metadata.behavior_table.start_t <= start_t + param.duration);
tab_bhv = metadata.behavior_table(poke_idx, :);


do_arena_view(t_axes.ax_arena, loc, metadata, param, pinfo.StartMinute)


lgd = plot_short_time(t_axes.ax_pos, t_axes.ax_vel, param, trial, ...
    loc, tab_bhv, ...
    zones, loc.Time(1), param.annotate);


