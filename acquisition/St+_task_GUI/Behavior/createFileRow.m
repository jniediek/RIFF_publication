function [T, paramFile] = createFileRow(Told,paramFileold,srcdir,filenames,trial_dur,att,speaker,noabort)
nstims = length(filenames);
filename = cell(size(filenames));
for i = 1:length(filenames)
    filename(i) = {[srcdir filenames{i} '.wav']};
end
type = cell(nstims, 1);
type(:) = {'file'};
type = categorical(type);

% speaker = speaker';

samp_rate = ones(nstims,1)*192000;

trial_dur = ones(nstims,1)*trial_dur;

stime = zeros(nstims,1);
etime = trial_dur;
ramp = zeros(nstims,1);

played = cell(nstims, 1);
played(:) = {'no'};
played = categorical(played,{'yes','no'});

att = ones(nstims,1)*att;

Tsize = size(Told,1);
paramsize = size(paramFileold,1);

paramline = (paramsize+1:paramsize+nstims)';
Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att,noabort,paramline,played);
T = [Told; Tnew];

line = (Tsize+1:Tsize+nstims)';

paramFilenew = table(line, filename);
paramFile = [paramFileold; paramFilenew];