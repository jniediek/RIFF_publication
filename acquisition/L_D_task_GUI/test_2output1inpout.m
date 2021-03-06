devType = 'asio';
firstCha = 4;
lastCha = 4;
%% test Speaker output
pa_wavplay(sigSpeaker/10 ,fs,0,devType)

%% test earphone output
pa_wavplay(sigEarphone,fs,0,devType)


%% test input
buffer = pa_wavrecord(firstCha, lastCha, fs, fs, 0,devType);
plot(buffer);

%% test playrec from Earphone
Amp = 0.1;
dur = duration;
buffer  = pa_wavplayrecord(sigEarphone*Amp,0,fs,fs*dur*2,firstCha, lastCha,0,devType);
plot(buffer);

%% test playrec from Speaker
Amp = 1;
dur = duration;
buffer  = pa_wavplayrecord(sigSpeaker*Amp,0,fs,fs*dur*2,firstCha, lastCha,0,devType);
plot(buffer);

%% Create Data

fs = 192000; %44100;
duration = 0.5; 
shift = 100; %size of window 's slope (in samples)
freq1 = 1000;


win=[linspace(0,1,fs/shift) ones(1,fs*duration-2*(fs/shift)) linspace(1,0,fs/shift)];  
sigR = sin(2*pi/fs*freq1*(1:fs*duration)); % sin in freq1Hz, duration second length
%sigL = sin(2*pi/fs*freq2*(1:fs*duration)); % sin in freq2Hz, duration second length

sigR = sigR .* win;
emptysig = zeros(length(sigR),1);
sigEarphone= [emptysig sigR'];
sigSpeaker  = [sigR' emptysig ];
disp('done')

%sigL = sigL .* win;

