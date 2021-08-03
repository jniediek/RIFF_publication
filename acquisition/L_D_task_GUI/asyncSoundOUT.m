function asyncSoundOUT(q)
send(q,'start');
qout=parallel.pool.PollableDataQueue;
send(q,qout);
dev=audioDeviceWriter;
dev.Driver='ASIO';
dev.Device='ASIO MADIface USB';
dev.SampleRate=192000;
dev.ChannelMappingSource='Property';
dev.ChannelMapping=1:14;
dev.SupportVariableSizeInput=true;
dev.BufferSize = 480;
send(q,dev);
gotMsg = false;
while ~gotMsg
    [zerarr,gotMsg] = poll(qout);
end
dev(zerarr);
msg = 1;
send(q,msg);
n=0;
firstRound=1;
playing = [0 0];
while true
    [data,gotMsg] = poll(qout);
    if gotMsg
        if isnumeric(data)
            playing = size(data);
            %play sound
            dev(toplay);            
            if firstRound
                pause(0.1);
                firstRound=0;
            end
            send(q,playing);

        elseif strcmp(data,'soundIsPlaying')
            n=dev(zeros(1,14));
            send(q,n);
        elseif strcmp(data,'exit')
            send(q,'worker exits');
            break;
        end
    end
end

end