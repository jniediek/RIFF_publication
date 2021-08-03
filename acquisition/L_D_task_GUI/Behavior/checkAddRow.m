load('stimulusListFile');
stimlist = S;
for k=5:5:100
    stim=struct;
    [stim.T, stim.paramFile,stim.paramBBN,stim.paramF,stim.paramGap] = ...
        createFileRow(stimlist.T,stimlist.paramFile,stimlist.paramBBN,stimlist.paramF,stimlist.paramGap,...
        'safety.wav',500,k);
    stimlist=stim;
end