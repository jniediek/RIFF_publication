date = '07.10.20';
filenum = 6;
%%
load(['C:\maestro_results\Analog_data',date,'\Tables_',num2str(filenum),'.mat'])
mdp_table = MDPData.MDPStates;
loc = find(mdp_table.type == 'A' | mdp_table.type == 'B' |mdp_table.type == 'C');
reward = 0;
mistake = 0;
miss = 0;
for ii = 1:length(loc)-1
    tmpT = mdp_table(loc(ii):loc(ii+1),:);
    resp = find(tmpT.type == 'Feedback',1,'first');
    if tmpT.behavior(resp) == 'reward'
        reward = reward+1;
    elseif tmpT.strig(resp) - tmpT.strig(2) > 20
        miss = miss+1;
    else
        mistake = mistake+1;
    end
end
disp(['rewards: ',num2str(reward),', mistakes: ',num2str(mistake),', no response: ',num2str(miss)]);