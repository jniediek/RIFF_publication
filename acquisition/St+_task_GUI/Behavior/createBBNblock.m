function [T, paramBBN] = createBBNblock(Told,paramBBNold,pr, nstims)

% pr = struct('speaker',[],'samp_rate',[],'trial_dur',[],'stime',[],'etime',[],'ramp',[],'att',[],'nstims',[]);
Tsize = size(Told,1);
paramsize = size(paramBBNold,1);
if pr.nstims
    nstims = pr.nstims;
% else
%     nstims = 280;
end
type = cell(nstims, 1);
type(:) = {'BBN'};
type = categorical(type);

if pr.speaker
    speaker = pr.speaker;
else
    speaker = ones(nstims,1)*3;
end
if pr.samp_rate
    samp_rate = pr.samp_rate;
else
    samp_rate = ones(nstims,1)*192000;
end
if pr.trial_dur
    trial_dur = pr.trial_dur;
else
    trial_dur = ones(nstims,1)*500;
end
if pr.stime
    stime = pr.stime;
else
    stime = ones(nstims,1)*100;
end
if pr.etime
    etime = pr.etime;
else
    etime = ones(nstims,1)*300;
end
if pr.ramp
    ramp = pr.ramp;
else
    ramp = ones(nstims,1)*10;
end
n = randi(1000000,1);
rng(n,'twister');
seed = rng;
if pr.att
    att = pr.att;
else
%     amps = 0:10:60;
%     reps = 40;
%     att = repmat(amps,reps,1);
%     att=att(:);
%     att=att(randperm(length(att)));
    att = ones(nstims,1)*30;
end
paramline = (paramsize+1:paramsize+nstims)';
% played = zeros(nstims,1);
played = cell(nstims, 1);
played(:) = {'no'};
played = categorical(played,{'yes','no'});
Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
T = [Told; Tnew];
seed = repmat(seed,nstims,1);
line = (Tsize+1:Tsize+nstims)';
paramBBNnew = table(line, seed);
paramBBN = [paramBBNold; paramBBNnew];