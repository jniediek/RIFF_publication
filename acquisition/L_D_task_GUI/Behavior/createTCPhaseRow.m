function [T, paramFile,paramBBN,paramF,paramGap] = createTCPhaseRow(Told,paramFileold,paramBBN,paramF,paramGap,filename,trial_dur,location)

type = categorical({'file'});
speaker = 3;
samp_rate = 192000;
stime = 50;
etime = 150;
ramp = 10;
played = categorical({'no'},{'yes','no'});
att = 10;

paramsize = size(paramFileold,1);
paramline = paramsize+1;

Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);

Tsize = size(Told,1);
if Tsize < location
    T = [Told; Tnew];
else
    Ttmp = Told(location:end,:);
    Told = Told(1:location-1,:);
    T = [Told;Tnew;Ttmp];
    sel=find(Ttmp.type=='freq');
    if ~isempty(sel)
        paramF.line(Ttmp.paramline(sel))=paramF.line(Ttmp.paramline(sel))+1;
    end
    sel=find(Ttmp.type=='silence');
    if ~isempty(sel)
        paramF.line(Ttmp.paramline(sel))=paramF.line(Ttmp.paramline(sel))+1;
    end
    sel=find(Ttmp.type=='BBN');
    if ~isempty(sel)
        paramBBN.line(Ttmp.paramline(sel))=paramBBN.line(Ttmp.paramline(sel))+1;
    end
    sel=find(Ttmp.type=='gap');
    if ~isempty(sel)
        paramGap.line(Ttmp.paramline(sel))=paramGap.line(Ttmp.paramline(sel))+1;
    end
end
line = location;
filename={filename};
paramFilenew = table(line, filename);
paramFile = [paramFileold; paramFilenew];