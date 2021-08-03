bb=zeros(12,0);
tt=[];
s=setupDaqSession(); % Initialize daq session
while 1>0
    tt(end+1)=cputime;
    beamind=InputBeams(s); % read beams
    bb(:,end+1)=0;
    if beamind(1)
    bb(beamind,end)=1;
    end
    while cputime-tt(end)<0.001
    end
end
%%
deleteDaqSession(s); % When fininshed, delete daq session
