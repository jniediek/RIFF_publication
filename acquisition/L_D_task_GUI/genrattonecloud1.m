% generates 10 tone clouds of dur with 6 time slices. each time slice summing over
% 6 tones (1 tone per/octave from the frequency table).
clear all

f1=1000;
f2=64000;
nfreq=37;
fs=192000;
dur=0.1;
ramps=0.01*fs;
freqtable=exp(linspace(log(f1),log(f2),nfreq));
Hz=2*pi/(fs);
rep=1;
t=1:fs*dur*rep;
% make time slices
tlen=floor(length(t)/(6*rep));
lend=0;
for ii=1:6*rep,
    tslice(ii,1)=lend+1;
    tslice(ii,2)=tslice(ii,1)+tlen-1;
    lend=tslice(ii,2);
end
% prepare window
win=[linspace(0,1,ramps/2) ones(1,tlen-ramps) linspace(1,0,ramps/2)];
toperm=[];
for ir=1:rep,
    toperm=[toperm 1:6];
end
onsetflag=1;
%%
plotflag=1;
pathn='~/Documents/MATLAB/clouds/stimuli';
for icloud=1%:100,
sig=zeros(1,length(t)+tlen);
phases=rand(6,6*rep)*2*pi;
onsets=floor(rand(6,6*rep)*tlen)*onsetflag;
freqs=zeros(6,6*rep);
for ii=1:6,
%     p=[];
%     for ir=1:rep
%         p=[p randperm(6)];
%     end
    p=toperm(randperm(length(toperm)));
    
    for jj=1:6*rep,
        sig((tslice(jj,1):tslice(jj,2))+onsets(ii,jj))=...
            sig((tslice(jj,1):tslice(jj,2))+onsets(ii,jj))+...
            sin(freqtable((ii-1)*6+p(jj))*Hz*(1:tlen)+phases(ii,jj)).*win;
        freqs(ii,jj)=freqtable((ii-1)*6+p(jj));
    end

end
sig=sig/(max(abs(sig)))*0.9999;
if plotflag,
spectrogram(sig,882,810,882*2,fs)
pause
end
% filename
filen=strcat('cloud_',date,'_',num2str(icloud));
% parameters for wav generation
cloud.freqrange=[f1 f2];
cloud.nfreq=nfreq;
cloud.freqs=freqs;
cloud.fs=fs;
cloud.fspace='exp';
cloud.ramps=ramps;
cloud.rampshape='linear';
cloud.dur=dur;
cloud.phases=phases;
cloud.onsets=onsets;
cloud.signal=sig;
cloud.date=date;
could.filen=filen;
save(fullfile(pathn,filen),'cloud')
%
wavwrite(sig,fs,16,fullfile(pathn,filen))
end
%% generate wav
