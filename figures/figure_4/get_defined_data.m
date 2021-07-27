function [loc, trial] = get_defined_data(year, month, day, rat)
% JN 2020-07-01

fname = fullfile('..', 'data', 'trial_data.mat');

S = load(fname);
loc = S.all_locs;
tr = S.all_trials;

idx_loc = loc.Year > 0;
idx_tr = tr.Year > 0;

if year > 0
    idx_loc = idx_loc & (loc.Year == year);
    idx_tr = idx_tr & (tr.Year == year);
end

if month > 0
    idx_loc = idx_loc & (loc.Month == month);
    idx_tr = idx_tr & (tr.Month == month);
end

if day > 0
    idx_loc = idx_loc & (loc.Day == day);
    idx_tr = idx_tr & (tr.Day == day);
end

if rat > 0
    idx_loc = idx_loc & (loc.Rat == rat);
    idx_tr = idx_tr & (tr.Rat == rat);
end

loc = loc(idx_loc, :);
trial = tr(idx_tr, :);