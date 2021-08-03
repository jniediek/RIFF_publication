function [T, paramF] = createFSblock(Told,paramFold,att)

type = cell(370, 1);
type(:) = {'freq'};
type = categorical(type);
speaker = ones(370,1)*3;
samp_rate = ones(370,1)*192000;
trial_dur = ones(370,1)*500;
stime = ones(370,1)*200;
etime = ones(370,1)*250;
ramp = ones(370,1)*5;
% played = zeros(370,1);
played = cell(370, 1);
played(:) = {'no'};
played = categorical(played,{'yes','no'});
att = repmat(att,370,1);
Tsize = size(Told,1);
paramsize = size(paramFold,1);

paramline = (paramsize+1:paramsize+370)';
Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
T = [Told; Tnew];

phase = zeros(370,1);

freq = exp(linspace(log(1000),log(64000),37));
freq = repmat(freq,1,10);
% n = randi(1000000,1);
% rng(n,'twister');
% seed = repmat(rng,370,1);
freq = freq(randperm(length(freq)))';

line = (Tsize+1:Tsize+370)';
paramFnew = table(line, freq, phase); %, seed
paramF = [paramFold; paramFnew];