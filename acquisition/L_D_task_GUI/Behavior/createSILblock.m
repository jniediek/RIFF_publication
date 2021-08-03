function [T, paramF] = createSILblock(Told,paramFold,nstims)

% nstims=33;
type = cell(nstims, 1);
type(:) = {'freq'};
type = categorical(type);
speaker = ones(nstims,1)*3;
samp_rate = ones(nstims,1)*192000;
% trial_dur = ones(nstims,1)*70;
% stime = ones(nstims,1)*10;
% etime = ones(nstims,1)*60;
trial_dur = ones(nstims,1)*500;
stime = ones(nstims,1)*200;
etime = ones(nstims,1)*250;
ramp = ones(nstims,1)*5;
% played = zeros(370,1);
played = cell(nstims, 1);
played(:) = {'no'};
played = categorical(played,{'yes','no'});
att = repmat(120,nstims,1);
Tsize = size(Told,1);
paramsize = size(paramFold,1);

paramline = (paramsize+1:paramsize+nstims)';
Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
T = [Told; Tnew];

phase = zeros(nstims,1);

freq = 5000*ones(nstims,1);

line = (Tsize+1:Tsize+nstims)';
paramFnew = table(line, freq, phase); %, seed
paramF = [paramFold; paramFnew];