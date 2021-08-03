function StimulusList(fs,bf)
% S a structure containing the sound sequence and its parameters
% sig: the sound sequence
% Properties of each sound sequence played:
% type: BBN / sine (=SSA or FS) / gap / silence / file (=food/water)
% speaker: the speaker it will play from, for now = 3
% trial_dur: in ms, usually 500 or 300 (different from block to block)
% stime: start time of sound
% etime: end time of sound
% ramp: start and end of sound, in ms
% params: specific parameters of the block/ file
% for BBN: amps (in dB attenuation, usually 0-60), reps (number of
% repetitions of each level), seq (sequence of attenuations)
% for FS: name (FS), amp(in dB attenuation), f_range (frequency range),
% f_num (number of different frequencies to play), reps (number of
% repetitions of each frequency)
% for SSA blocks: name(H,L,E,1,2,D,M), amp (in dB attenuation),
% bf (best frequency), seq (sequence of frequencies)
% for gap blocks: name (gap_std, gap_dev), amp (in dB attenuation),
% gap (length in ms), sgap (start time of gap from stime)
% for gaps-sweep: name (all_gaps), amp (in dB attenuation), gaps (in
% ms, usually 0-20), reps (number of repetiotions of each gap length)
% for file: filename
S = struct('sig',{},'type',{},'speaker',{},'trial_dur',{},'stime',{},'etime',{},'ramp',{},'params',{});

%general features
fs = 44100;
sp = 3;
r = 100;
len = r*(1+5+7+6+1);
idx = randperm(len);
%--------------------------------------------------------------------------
% create BBN block
stime = 100;
etime = 300;
ramp = 10;
trial_dur = 500;
amps = 0:10:60;
reps = 40;
seq = repmat(amps,reps,1);
seq=seq(:);
ssil = zeros(1,fs/1000*stime);
esil = zeros(1,fs/1000*(trial_dur - etime));
n = fs/1000*(etime-stime);
bbn = randn(1, n);           % Gausian noise
bbn = bbn / max(abs(bbn));   % -1 to 1 normalization
win = [linspace(0,1,fs/1000*ramp) ones(1,fs/1000*(etime-stime)-2*fs/1000*ramp) linspace(1,0,fs/1000*ramp)];
bbn = bbn.*win;    % with window
for jj = 1:(r*1)
    seq=seq(randperm(length(seq)));
    sig = [];
    for ii = 1:length(seq)
        if seq(ii) ~= 0
            sig = [sig ssil bbn./20*log10(seq(ii)) esil];
        else
            sig = [sig ssil bbn esil]; %*****
        end
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'BBN';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.amps = amps;
    S(idx(jj)).params.reps = reps;
    S(idx(jj)).params.seq = seq;
end
%--------------------------------------------------------------------------
%create FS blocks

%--------------------------------------------------------------------------
%create SSA blocks
bf = 6000;
df=2^(1/6);
Hz=2*pi/44100;
stime = 50;
etime = 80;
ramp = 5;
trial_dur = 300;
amp = 30;
ssil = zeros(1,fs/1000*stime);
esil = zeros(1,fs/1000*(trial_dur - etime));
n = 1:fs/1000*(etime-stime)-1;
win = [linspace(0,1,fs/1000*ramp) ones(1,fs/1000*(etime-stime)-2*fs/1000*ramp) linspace(1,0,fs/1000*ramp)];
%high is standard
for jj = (r*1+1):(r*2)
    seq = ones(500,1);
    seq(randsample(500,25)) = 2;
    sig = [];
    for ii = 1:length(seq)
        if seq(ii) == 1
            sig=[sig ssil sin(bf*df*Hz*n).*win esil];
        else
            sig=[sig ssil sin(bf/df*Hz*n).*win esil];
        end
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'sine';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.name = 'H';
    S(idx(jj)).params.amp = amp;
    S(idx(jj)).params.seq = seq;
end
%low is standard
for jj = (r*2+1):(r*3)
    seq = ones(500,1);
    seq(randsample(500,475)) = 2;
    sig = [];
    for ii = 1:length(seq)
        if seq(ii) == 1
            sig=[sig ssil sin(bf*df*Hz*n).*win esil];
        else
            sig=[sig ssil sin(bf/df*Hz*n).*win esil];
        end
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'sine';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.name = 'L';
    S(idx(jj)).params.amp = amp;
    S(idx(jj)).params.seq = seq;
end
%equal
for jj = (r*3+1):(r*4)
    seq = ones(500,1);
    seq(randsample(500,250)) = 2;
    sig = [];
    for ii = 1:length(seq)
        if seq(ii) == 1
            sig=[sig ssil sin(bf*df*Hz*n).*win esil];
        else
            sig=[sig ssil sin(bf/df*Hz*n).*win esil];
        end
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'sine';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.name = 'E';
    S(idx(jj)).params.amp = amp;
    S(idx(jj)).params.seq = seq;
end
%high alone
for jj = (r*4+1):(r*5)
    seq = zeros(500,1);
    seq(randsample(500,25)) = 1;
    sig = [];
    for ii = 1:length(seq)
        if seq(ii) == 1
            sig=[sig ssil sin(bf*df*Hz*n).*win esil];
        else
            sig=[sig ssil sin(bf/df*Hz*n).*0 esil];
        end
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'sine';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.name = '1';
    S(idx(jj)).params.amp = amp;
    S(idx(jj)).params.seq = seq;
end
%low alone
for jj = (r*5+1):(r*6)
    seq = zeros(500,1);
    seq(randsample(500,25)) = 2;
    sig = [];
    for ii = 1:length(seq)
        if seq(ii) == 0
            sig=[sig ssil sin(bf*df*Hz*n).*0 esil];
        else
            sig=[sig ssil sin(bf/df*Hz*n).*win esil];
        end
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'sine';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.name = '2';
    S(idx(jj)).params.amp = amp;
    S(idx(jj)).params.seq = seq;
end
%diverse broad
for jj = (r*6+1):(r*7)    
    seq = [repmat([-11:2:-3,3:2:11],1,45) repmat([-1 1],1,25)];
    seq = seq(randperm(length(seq)));
    sig = [];
    for ii = 1:length(seq)
        sig=[sig ssil sin(bf*df^(seq(ii))*Hz*n).*win esil];
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'sine';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.name = 'M';
    S(idx(jj)).params.amp = amp;
    S(idx(jj)).params.seq = seq;
end
%diverse narrow
for jj = (r*7+1):(r*8) 
    seq = linspace(bf/df^(19/11),bf*df^(19/11),20);
    seq = repmat(seq,1,25);
    seq = seq(randperm(length(seq)));
    sig = [];
    for ii = 1:length(seq)
        sig=[sig ssil sin(seq(ii)*Hz*n).*win esil];
    end
    S(idx(jj)).sig = sig;
    S(idx(jj)).type = 'sine';
    S(idx(jj)).speaker = sp;
    S(idx(jj)).trial_dur = trial_dur;
    S(idx(jj)).stime = stime;
    S(idx(jj)).etime = etime;
    S(idx(jj)).ramp = ramp;
    S(idx(jj)).params.name = 'M';
    S(idx(jj)).params.amp = amp;
    S(idx(jj)).params.seq = seq;
end
end

%%
fs=44100;
Hz=2*pi/44100;
fr=500;
df=2^(1/6);
seq=1:13;
seq=repmat(seq,4,1);
seq=seq(:);
seq=seq(randperm(length(seq)));
t=(1:441*3);
sil=zeros(1,44100/1000*270);
sig=[];
win=[linspace(0,1,44) ones(1,441*3-2*44) linspace(1,0,44)];
for ii=1:length(seq)
    sig=[sig sin(fr*df^(seq(ii)-1)*Hz*t).*win sil];
end