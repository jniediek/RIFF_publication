function [T, paramGap] = createGapRow(Told,paramGapold,gaplen)

type = categorical({'gap'});
speaker = 3;
samp_rate = 192000;
trial_dur = 500;
stime = 100;
etime = 300;
ramp = 10;
% played = 0;
played = categorical({'no'},{'yes','no'});
att = 40;

Tsize = size(Told,1);
paramsize = size(paramGapold,1);

paramline = paramsize+1;
Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
T = [Told; Tnew];

line = Tsize+1;
sgap = 150;
egap = sgap + gaplen;
ramp = 0;
paramGapnew = table(line, sgap, egap, ramp);
paramGap = [paramGapold; paramGapnew];
