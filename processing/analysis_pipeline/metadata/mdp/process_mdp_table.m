function mdp_table = process_mdp_table(mdp_table, rat_states, experiment)
% JN 2019-07-04

mdp_table.Properties.VariableNames{'area'} = 's_area';

rat_states.loc_x = rat_states.loc(:, 1);
rat_states.loc_y = rat_states.loc(:, 2);

rat_states = removevars(rat_states, {'loc'});

switch experiment
    case 'Ana'
        rat_states.Properties.VariableNames{'area'} = 'r_area';
    case 'Maciej'
        mdp_table.Properties.VariableNames{'type'} = 's_areatype';
        
        n_rat_states = height(rat_states);
        type_var = repmat(' ', n_rat_states, 1);
        
        areas = rat_states.area;
        nums = zeros(n_rat_states, 1);
        
        for i=1:n_rat_states
            t = char(areas(i).type);
            num = areas(i).num;
            nums(i) = num;
            type_var(i) = t(1);
        end
        
        rat_states.r_area = nums;
        rat_states.r_areatype = type_var;
        
    case 'nightRIFF'
        keys = {'center', 'repeat'};
        invalid = categorical("invalid");
        for i = 1:2
            tkey = keys{i};
            sndi = find(mdp_table.type == tkey);
            mdp_table.type(sndi(diff(sndi) == 1)) = invalid;
        end
end

mdp_table = [mdp_table rat_states];
