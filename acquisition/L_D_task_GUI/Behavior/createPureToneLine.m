function [T, paramF] = createPureToneLine(Told, paramFold, att, freq, nstims, speaker)

type = cell(nstims, 1);
type(:) = {'freq'};
type = categorical(type);
% speaker = ones(nstims,1)*3;
speaker = speaker';
samp_rate = ones(nstims,1)*192000;
trial_dur = ones(nstims,1)*500;
stime = ones(nstims,1)*200;
etime = ones(nstims,1)*250;
% trial_dur = ones(nstims,1)*70;
% stime = ones(nstims,1)*10;
% etime = ones(nstims,1)*60;
ramp = ones(nstims,1)*5;
% played = zeros(nstims,1);
played = cell(nstims, 1);
played(:) = {'no'};
played = categorical(played,{'yes','no'});
% att = repmat(att,nstims,1);
att = att';
Tsize = size(Told,1);
paramsize = size(paramFold,1);

paramline = (paramsize+1:paramsize+nstims)';
Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
T = [Told; Tnew];

phase = zeros(nstims,1);

% freq = exp(linspace(log(1000),log(64000),37));
% freq = repmat(freq,1,10);
% n = randi(1000000,1);
% rng(n,'twister');
% seed = repmat(rng,nstims,1);
% freq = freq(randperm(length(freq)))';
freq = freq';

line = (Tsize+1:Tsize+nstims)';
paramFnew = table(line, freq, phase); %, seed
paramF = [paramFold; paramFnew];