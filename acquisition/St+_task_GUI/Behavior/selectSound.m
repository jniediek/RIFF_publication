 function [toPlay, toReward] = selectSound(behavior, area, toReward, handles)
% stimdir : area|good sound|bad sound|neutral sound|probabilities
% behavior: area(1-n)|IA number(1-12)|behavior type(1-eat,2-drink,3-get airpuff| response(reward/punishment/nothing)
% toPlay: index in the stimulusList of the sound that should be played
% toReward: which reward state should happen now
if area == 0 %for now, in area = 0, we don't play anything
    toPlay = 0;
    toReward.state = 'no';
    return
end

type = 0;
if toReward.beamind > 0
    type = IdentifyType(toReward);
end
stimdir = handles.stimdir;
%looking at the last 10 actions of the animal (or as much as there are)
look_back = height(behavior);
if look_back > 10
    look_back = 10;
elseif look_back == 0 && toReward.beamind == 0 %first sound with no action should be a good one
    toPlay = stimdir.good(area);
    toReward.state = 'go'; %reward
    return
elseif  look_back == 0 && toReward.beamind > 0 %first sound with no action should be a good one    
    switch type
        case 1
            toPlay = stimdir.food(area);
        case 2
            toPlay = stimdir.water(area);
    end
    toReward.state = 'go'; %reward
    return
end
recent_behav = behavior(end-look_back+1:end,:);
visited = recent_behav.area;
visited_ind = find(visited == area);
if isempty(visited_ind)
    visited_ind = 0;
end
reward = find(recent_behav.response == 'reward');
punish = find(recent_behav.response == 'punishment');
if isempty(punish)
    punish = 0;
end
p = stimdir.p(area,:);
%if there is too much punishment already or last response from riff or from
%this IA was a punishment, play a good sound
if length(punish)/length(reward) > p(2)/p(1) || strcmp(recent_behav.response(end),'punishment') || visited_ind(end) == punish(end)
    toPlay = stimdir.good(area);
    switch type
        case 1
            toPlay = stimdir.food(area);
        case 2
            toPlay = stimdir.water(area);
    end
    toReward.state = 'go'; %reward
else
    switch find(mnrnd(1,p))
        case 1
            toPlay = stimdir.good(area);
            switch type
                case 1
                    toPlay = stimdir.food(area);
                case 2
                    toPlay = stimdir.water(area);
            end
            toReward.state = 'go'; %reward
        case 2
            toPlay = stimdir.bad(area);
            toReward.state = 'punish'; %punishment
        case 3
            toPlay = stimdir.neutral(area);
            toReward.state = 'no'; %nothing
    end
end