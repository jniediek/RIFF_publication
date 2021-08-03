function S = StimulusList(filename,dbr) %bf,fra_att, ssa_att, repeats
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
srcdir=fullfile(s,'word_stimuli\');
soundtype = {'reward';'reward';'reward';'reward';'reward';'reward';'init'};

% [T, paramF] = createSILblock(T,paramF,18);
speakers = {[1,2];[3,4];[5,6];[7,8];[9,10];[11,12]};
rword = {'pol_yolande_tam';'rus_gulnara_tut';'deu_katrin_da';'ita_marta_qui';'eng-uk_judith_here';'fra_vion_la'};
% rewlen = 2000*60;
rewlen = 2000;
nblen = ones(6,1)*0.2*192000;
sdur = round(nblen/192);
for ii = 1:6
    [T, paramFile] = createFileRow(T,paramFile,srcdir,rword(ii),rewlen,dbr,speakers(ii),nblen(ii)); %reward
%     [T, paramFile] = createFileRow(T,paramFile,srcdir,rword(ii),rewlen,dbr,{1:12},nblen(ii)); %reward
end

tt = 96000;
sdur = [sdur; tt/192];
[T, paramFile] = createFileRow(T,paramFile,srcdir,{'silence'},500,120,{1:12},tt); %init
soundtype = categorical(soundtype);
area = [1:6 0]';
% area = [1:6]';
typecol = table(sdur,soundtype,area);

T = [T typecol];

% S = struct('T',T,'paramBBN',paramBBN,'paramF',paramF,'paramGap',paramGap,'paramFile',paramFile);
S = struct('T',T,'paramFile',paramFile);
save(['stim_tables/',filename],'S');
