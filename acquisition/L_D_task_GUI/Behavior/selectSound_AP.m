function [toPlay, toReward] = selectSound_AP(soundseq, area, toReward, handles)
% stimdir : area|good sound|bad sound|neutral sound|probabilities
% behavior: area(1-n)|IA number(1-12)|behavior type(1-eat,2-drink,3-get airpuff| response(reward/punishment/nothing)
% toPlay: index in the stimulusList of the sound that should be played
% toReward: which reward state should happen now
if area == 0 %for now, in area = 0, we don't play anything
    toPlay = 0;
    toReward.state = 'no';
    return
end
% SOUNDS DEPEND ONLY ON LOCATION, NOT ON NOSE POKING (FOR NOW)
% type = 0;
% if toReward.beamind > 0
%     type = IdentifyType(toReward);
% end
stimdir = handles.stimdir;
if height(soundseq) > 0
    idx = find(soundseq.played == 'yes');
    if ~isempty(idx)
        soundseq = soundseq(idx,:);
    end
end
%looking at the last 10 actions of the animal (or as much as there are)
look_back = height(soundseq);
if look_back > 1000
    look_back = 1000;
elseif look_back == 0 && toReward.beamind == 0 %first sound with no action should be a good one
    toPlay = stimdir.good(area);
    toReward.state = 'go'; %reward
    return
% elseif  look_back == 0 && toReward.beamind > 0 %first sound with no action should be a good one
%     switch type
%         case 1
%             toPlay = stimdir.food(area);
%         case 2
%             toPlay = stimdir.water(area);
%     end
%     toReward.state = 'go'; %reward
%     return
end
% recent_behav = behavior(end-look_back+1:end,:);
% visited = recent_behav.area;
recent_sounds = soundseq(end-look_back+1:end,:);
visited = recent_sounds.area;

visited_ind = find(visited == area);
if isempty(visited_ind)
    toPlay = stimdir.good(area);
    toReward.state = 'go'; %reward
    return
elseif look_back > 1 && soundseq.area(end-1) ~= area
    toPlay = stimdir.good(area);
    toReward.state = 'go'; %reward
    return
end
% reward = find(recent_behav.response == 'reward');
% punish = find(recent_behav.response == 'punishment');
good = find(recent_sounds.soundtype == 'good');
% bad = find(recent_sounds.soundtype == 'bad'); % NO BAD SOUNDS YET, ONLY GOOD (REWARD) OR NEUTRAL (NO REWARD)
neutral = find(recent_sounds.soundtype == 'neutral');
% if isempty(bad)
%     bad = 0;
% end
if isempty(neutral)
    neutral = 0;
end
p = stimdir.p(area,:);

%find how many consecutive neutrals were there (if we're now playing neutrals)
last = neutral(end);
count = 0;
while length(neutral) > count+1 && last == look_back - count
    count = count+1;
    last = neutral(end-count);
end


if count > 0 && count < 100
    toPlay = stimdir.neutral(area);
    toReward.state = 'no';
elseif length(neutral)/length(good) > p(3)/p(1)
    toPlay = stimdir.good(area);
    %     switch type
    %         case 1
    %             toPlay = stimdir.food(area);
    %         case 2
    %             toPlay = stimdir.water(area);
    %     end
    toReward.state = 'go'; %reward
else
    switch find(mnrnd(1,p))
        case 1
            toPlay = stimdir.good(area);
%             switch type
%                 case 1
%                     toPlay = stimdir.food(area);
%                 case 2
%                     toPlay = stimdir.water(area);
%             end
            toReward.state = 'go'; %reward
        case 2
            toPlay = stimdir.bad(area);
            toReward.state = 'punish'; %punishment
        case 3
            toPlay = stimdir.neutral(area);
            toReward.state = 'no'; %nothing
    end
end
end