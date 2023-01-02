function stimDir = createStimulusDir(handles) 

type = [];
area = [];
stimlistLine = [];

names = categorical({'reward';'punish';'timeout';'punishTO'});

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