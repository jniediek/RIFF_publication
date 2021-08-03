q=parallel.pool.PollableDataQueue;
f=parfeval(@asynchSound,0,q);
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
    [dev, gotMsg]=poll(q);
end
disp(dev)
data=[];
while ~strcmp(data,'exit')
    fr=input('Input frequency, -1 to exit: ');
    if fr>0
        data=[fr 192000];
    else
        data='exit';
    end
    send(qout,data);
    if strcmp(data,'exit')
        break;
    end
    gotMsg=false;
    while ~gotMsg
        [message, gotMsg]=poll(q);
    end
    disp(message);
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
