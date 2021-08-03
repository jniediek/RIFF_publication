function asynchSoundOUT_try(q)
send(q,'start');
qout=parallel.pool.PollableDataQueue;
send(q,qout);
% fs = 192000;
% dev = audioDeviceWriter;
% dev.Driver = 'ASIO';
% dev.Device = 'ASIO MADIface USB';
% dev.SampleRate = fs;
% dev.ChannelMappingSource = 'Property';
% dev.ChannelMapping = 1:14;
% dev.SupportVariableSizeInput = true;
% dev.BufferSize = 480;

send(q,'ready');
% Hz=2*pi/fs;
n=0;
firstRound=1;
while true
    [data,gotMsg] = poll(qout);
    if gotMsg
        if length(data) == 6
%             send(q,data);
%             sig=sin(Hz*data(1)*(1:data(2)));
%             ga=[linspace(0,1,fs/100) ones(1,data(2)-(fs/100)*2) linspace(1,0,fs/100)];
%             sig=sig(:).*ga(:);
%             sig=sig(:,ones(1,14));
%             dev(sig);
            app = data{1};
            soundinfo = data{2};
            loopnum = data{3};
            isInterrupted = data{4};
            zerarr = data{5};
            soundSequence = data{6};
            [soundSequence, isInterrupted, zerarr] = soundOUT(app, soundinfo, loopnum, isInterrupted, zerarr, soundSequence);
            data = {soundSequence; isInterrupted; zerarr};
            send(q,data);
            if firstRound
                pause(0.1);
                firstRound = 0;
            end
        elseif strcmp(data,'soundIsPlaying')
            n=dev(zeros(1,14));
            send(q,n);
        elseif strcomp(data,'exit')
            send(q,'worker exits');
            break;
        end
    end
end
    
