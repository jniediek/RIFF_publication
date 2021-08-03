date = '07.10.20';
filenum = 4;
%%
load(['C:\maestro_results\Analog_data',date,'\Tables_',num2str(filenum),'.mat'])
mdp_table = MDPData.MDPStates;
loc = find(mdp_table.type == 'A' | mdp_table.type == 'B' |mdp_table.type == 'C');
reward = [0 0 0];
mistake = reward;
miss = reward;
for ii = 1:length(loc)-1
    tmpT = mdp_table(loc(ii):loc(ii+1),:);
    resp = find(tmpT.type == 'Feedback',1,'first');
    switch tmpT.type(1)
        case 'A'
            if tmpT.behavior(resp) == 'reward'
                reward(1) = reward(1)+1;
            elseif tmpT.strig(resp) - tmpT.strig(2) > 20
                miss(1) = miss(1)+1;
            else
                mistake(1) = mistake(1)+1;
            end
        case 'B'
            if tmpT.behavior(resp) == 'reward'
                reward(2) = reward(2)+1;
            elseif tmpT.strig(resp) - tmpT.strig(2) > 20
                miss(2) = miss(2)+1;
            else
                mistake(2) = mistake(2)+1;
            end
        case 'C'
            if tmpT.behavior(resp) == 'reward'
                reward(3) = reward(3)+1;
            elseif tmpT.strig(resp) - tmpT.strig(2) > 20
                miss(3) = miss(3)+1;
            else
                mistake(3) = mistake(3)+1;
            end
    end    
end
sprintf('A: rewards %d, mistakes %d, misses %d',reward(1),mistake(1),miss(1))
sprintf('B: rewards %d, mistakes %d, misses %d',reward(2),mistake(2),miss(2))
sprintf('C: rewards %d, mistakes %d, misses %d',reward(3),mistake(3),miss(3))


warning = length(find(MetaData.sounds.soundtype == 'warning'));
safe = length(find(MetaData.sounds.soundtype == 'safe'));
punish = length(find(MetaData.sounds.soundtype == 'punish'));

sprintf('Warning: %d, Safe: %d, Punish: %d',warning,safe,punish)