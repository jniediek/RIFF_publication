function S = StimulusList(filename,dbl,dbg,dbw,delay) %bf,fra_att, ssa_att, repeats
% S a structure containing the sound parameters from which one can create a
% single trial
% bf - best frequency for SSA blocks; fra_att - list of attenuations for
% the frequency sweeps (in an array, for example 10:10:70); repeats - how
% many times shoould the protocols be played
%
% Properties of each sound sequence played:
% type: BBN / freq (=SSA or FS) / gap / silence / file (=food/water)
% speaker: the speaker it will play from, for now = 3
% trial_dur: in ms, usually 500 or 300
% stime: start time of sound
% etime: end time of sound
% ramp: start and end of sound, in ms
% att: attenuation in dB
% paramline: specific parameters of the block/ file
% played: 0 - no, 1 - yes
% parameters in param. Each param table will contain: line + special
% parameters for each type of data
% for BBN: seed - the random seed
% for sine: freq - frequency, phase, for silence, freq = 0;
% for gap: len (length of gap in ms), sgap (start time of gap from stime)
% for file: filename
% S = struct('type',{},'speaker',{},'samp_rate',{},'trial_dur',{},'stime',{},'etime',{},'ramp',{},'att',{},'paramline',{},'type',{},'played',{});
%general features

T = table();
% paramBBN = table();
% paramF = table();
paramFile = table();
pr = struct('speaker',[],'samp_rate',[],'trial_dur',[],'stime',[],'etime',[],'ramp',[],'att',[],'nstims',[], 'type', []);

s = pwd; % returns the current directory to the variable s.
srcdir=fullfile(s,'maciej_sounds\');
soundtype = {'att';'target';'target';'target';'target';'target';'target';...
    'reward';'reward';'reward';'reward';'reward';'reward';...
    'negative';'negative';'negative';'negative';'negative';'negative';'warning';'safe';'punish';'silence'};
[T, paramFile] = createFileRow(T,paramFile,srcdir,{'att_sound'},3050,dbg,{1:12},278400); %attention sound

% [T, paramF] = createSILblock(T,paramF,18);
sdur = [];
speakers = {[1,2];[3,4];[5,6];[7,8];[9,10];[11,12];};
noabtlen = 249600;
for ii = 1:6
    [T, paramFile] = createFileRow(T,paramFile,srcdir,{['target_',num2str(ii)]},21498,dbl,speakers(ii),noabtlen); %target sounds
    sdur = [sdur round(noabtlen/192)];
end
noabtlen = 144963;
for ii = 1:6
    [T, paramFile] = createFileRow(T,paramFile,srcdir,{'reward_sound'},3753,dbl,speakers(ii),noabtlen); %target sounds
    sdur = [sdur round(noabtlen/192)];
end
noabtlen = 169923;
for ii = 1:6
    [T, paramFile] = createFileRow(T,paramFile,srcdir,{'negative_sound'},3883,dbl,speakers(ii),noabtlen); %target sounds
    sdur = [sdur round(noabtlen/192)];
end
slen = [6835,1458,1218,1000];
noabtlen =  [352321,280321,234241,0];
sdur = [sdur round(noabtlen/192)];
dl = delay*192000;
noabtlen(1) = noabtlen+dl;
for jj = 20:23
    [T, paramFile] = createFileRow(T,paramFile,srcdir,{[soundtype{jj},'_sound']},slen(jj-19),dbw,{1:12},noabtlen(jj-19)); %target sounds
end
soundtype = categorical(soundtype);
area = [0:6 1:6 1:6 0 0 0 0]';
sdur = sdur';
typecol = table(sdur,soundtype,area);

T = [T typecol];

% S = struct('T',T,'paramBBN',paramBBN,'paramF',paramF,'paramGap',paramGap,'paramFile',paramFile);
S = struct('T',T,'paramFile',paramFile);
save(['stim_tables/',filename],'S');
