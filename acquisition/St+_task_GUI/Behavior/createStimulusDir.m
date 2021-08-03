function stimDir = createStimulusDir(handles)  %sounds,
% stimdir : sound type (attention, reward, none) | area in which it's
% played | line in stimulus list

% area = (1:areaN)';

type = [];
area = [];
stimlistLine = [];

names = categorical({'att';'target';'reward';'negative';'warning';'safe';'punish';'silence'});
% attention - same for all areas
% target - different for each area
% reward, negative, warning, safe, punish - same for all areas
% silence - for area D

T = handles.stimlist.T;

for jj = 1:length(names)
    idx = find(T.soundtype == names(jj));
    for kk = 1:length(idx)
        type = [type; names(jj)];
    end
    area = [area; T.area(idx)];
    stimlistLine = [stimlistLine; idx];
end
stimDir = table(type, area, stimlistLine);


% names = {'inner';'middle';'outer'};
% inner=[];
% middle=[];
% outer=[];
% for i =1:areaN
%     for j = 1:length(names)
%         if find(T.area == i & T.soundtype == names{j})
%             eval([names{j},' = [',names{j},'; find(T.area == i & T.soundtype == ''',names{j},''')];']);
%         else
%             eval([names{j},' = [',names{j},'; -1];']);
%         end
%     end
% end
% 
% stimDir = table(area, inner, middle, outer);
