filename='TCPTable.mat';
T = table();
paramBBN = table();
paramF = table();
paramGap = table();
paramFile = table();
pr = struct('speaker',[],'samp_rate',[],'trial_dur',[],'stime',[],'etime',[],'ramp',[],'att',[],'blockl',[]);
basedir='C:\Users\OWNER\Desktop\maestro_240416_32_chan\SoundFiles\Stimuli';
bfname='cloud_06-Oct-2016_';
[sig,fs]=audioread(fullfile(basedir,[bfname '1.wav']));
list=1:3000;
for ii=1:60
    list=[list (3000+ii)*ones(1,40)];
end
list=list(randperm(length(list)));
for ii=1:length(list)

[T, paramFile,paramBBN,paramF,paramGap] = createTCPhaseRow(T,paramFile,paramBBN,paramF,paramGap,...
    fullfile(basedir,[bfname num2str(list(ii)) '.wav']),500,ii);
end


S = struct('T',T,'paramBBN',paramBBN,'paramF',paramF,'paramGap',paramGap,'paramFile',paramFile);
save(['stim_tables/',filename],'S');
