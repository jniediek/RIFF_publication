function stat_data = cluster_stats(clustering_data, param)
% JN 2020-12-13, 2020-12-17


dset = clustering_data.dset;

irow = 1;

stat_data = zeros(length(param.rats) * length(param.days) * 2, 9);

for irat = 1:length(param.rats)
    rat = param.rats(irat);
    
    for iday = 1:length(param.days)
        day = param.days(iday);
        
        idxs = create_behav_clusters(dset(irat, iday).speed, param);
        
        n_trials = length(idxs{1});
        for i_half = 1:2
            selector = dset(irat, iday).trials.Half == i_half;
            stat_data(irow, 1:5) = [param.year, param.month, day, ...
                rat, i_half];
            
            for i_type = 1:3
                idx = idxs{i_type};
                base = zeros(n_trials, 1);
                base(idx) = 1;
                td = base(selector);
                stat_data(irow , 5 + i_type) = sum(td);
            end
            
            stat_data(irow, 9) = sum(selector);
            
            irow = irow + 1;
            
        end
    end
end

stat_data = array2table(stat_data, 'VariableNames', ...
    {'Year', 'Month', 'Day', 'Rat', 'Half', 'N_slow', ...
    'N_pos', 'N_neg', 'N_total'});


% JN 2020-12-17
% checked that N_total is the same as the sum of N_slow, N_pos, N_neg