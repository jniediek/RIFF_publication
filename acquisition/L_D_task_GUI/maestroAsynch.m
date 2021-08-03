function maestroAsynch
% [soundSequence, isInterrupted, zerarr] = maestroAsynch(app,soundinfo,loopnum,isInterrupted,zerarr,soundSequence)
q=parallel.pool.PollableDataQueue;
f=parfeval(@asynchSoundOUT,0,q);
gotMsg=false;
while ~gotMsg
    [startmessage, gotMsg]=poll(q);
end
disp(startmessage);
gotMsg=false;
while ~gotMsg
    [qout, gotMsg]=poll(q);
end
disp(qout)
gotMsg=false;
while ~gotMsg
    [readymsg, gotMsg]=poll(q);
end
disp(readymsg)
data=[];
while ~strcmp(data,'exit')
    fr = soundinfo.play;
    if fr > -1
        data = {app;soundinfo;loopnum;isInterrupted;zerarr;soundSequence};
    else
        data = 'exit';
    end
    send(qout,data);
    if strcmp(data,'exit')
        break;
    end
    gotMsg=false;
    while ~gotMsg
        [outputdata, gotMsg]=poll(q);
    end
    soundSequence = outputdata{1};
    isInterrupted = outputdata{2};
    zerarr = outputdata{3};
    n=0;
    while n==0
        data='soundIsPlaying';
        send(qout,data);
        gotMsg=false;
        while ~gotMsg
            [n, gotMsg]=poll(q);
        end
    end
    disp(n)
end
cancel(f);
