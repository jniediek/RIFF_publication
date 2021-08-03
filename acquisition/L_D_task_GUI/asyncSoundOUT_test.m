function asyncSoundOUT_test(q,sounds)
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
while true
    
     send(q,'inside loop');
    [data,gotMsg] = poll(qout);
    if gotMsg
        if isnumeric(data)    
            send(q,'debug msg');
            % prepare sound for playing
            snd_idx = data(1,1); %sound to play
            first_chan=sounds{snd_idx,1}; %the sound
            points = sounds{snd_idx,2}; %the base
            spkr = data(:,2); %speakers to play the sound
            spkr = spkr + 2;
            for ii = 1:length(spkr)
                points(:,spkr(ii))=first_chan{1};
            end
            routing = [1 2 ones(1,12)*-1];
            routing(spkr) = spkr;
            
            loc=find(~(routing==-1));
            % add a tiny bit to the length of the sound
            cur_trial_dur = sounds{snd_idx,4};
            samp_rate = sounds{snd_idx,3};
            addedLen = cur_trial_dur*samp_rate*0.001-size(points,1);
            tmp_points = cat(1,points(:,loc),zeros(addedLen,length(loc)));
            tmp_routing=routing(loc);
            
            toplay=zeros(length(tmp_points),length(routing));
            toplay(:,tmp_routing)=tmp_points;            
            send(q,'starting playing...');
            %play sound
            dev(toplay);            
            if firstRound
                pause(0.1);
                firstRound=0;
            end
            
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