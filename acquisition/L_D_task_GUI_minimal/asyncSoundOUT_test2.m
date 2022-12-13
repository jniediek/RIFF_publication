function asyncSoundOUT_test2(q,sounds)
send(q,'start');
qout=parallel.pool.PollableDataQueue;
send(q,qout);
S=load(sounds);
sounds=S.sounds_data;
dev=audioDeviceWriter;
dev.Driver='ASIO';
dev.Device='ASIO MADIface USB';
dev.SampleRate=192000;
dev.ChannelMappingSource='Property';
dev.ChannelMapping=1:14;
dev.SupportVariableSizeInput=true;
dev.BufferSize = 480*2;
send(q,dev);
gotMsg = false;
while ~gotMsg
    [zerarr,gotMsg] = poll(qout);
end
dev(zerarr);
msg = 1;
send(q,msg);
n=0;
isPlaying=0;
bufInd=0;
while true
    %send(q,'inside loop');
    [data,gotMsg] = poll(qout);
    if gotMsg
        if isnumeric(data)    
            send(q,'debug msg');
            % prepare sound for playing
            snd_idx = data(1,1); %sound to play
            samp_rate = sounds{snd_idx,3}; %sampling rate
            first_chan=sounds{snd_idx,1}; %the sound
            points = zeros(length(first_chan{1}),14); %the base
            %the trigger for SnR (channel 50 TTL)
            RXsr=48000;
            fr=RXsr/3;
            np=samp_rate/fr;
            np=ceil(samp_rate*0.01/np)*np;
            points(1:np,2)=sin(2*pi/samp_rate*fr*(1:np));
            points(np+1:end,2)=0;
            spkr = data(:,2); %speakers to play the sound
            spkr = spkr + 2;
            for ii = 1:length(spkr)
                points(:,spkr(ii))=first_chan{1}(:);
            end
            routing = [1 2 ones(1,12)*-1];
            routing(spkr) = spkr;
            
            loc=find(~(routing==-1));
            % add a tiny bit to the length of the sound
            cur_trial_dur = sounds{snd_idx,4};
            addedLen = cur_trial_dur*samp_rate*0.001-size(points,1);
            tmp_points = cat(1,points(:,loc),zeros(addedLen,length(loc)));
            tmp_routing=routing(loc);
            
            toplay=zeros(length(tmp_points),length(routing));
            toplay(:,tmp_routing)=tmp_points;            
            send(q,'starting playing...');
            %play sound
            bufInd=0;
            noabort=sounds{snd_idx,2};
            dev(toplay(bufInd+(1:dev.BufferSize),:));  
            bufInd=bufInd+dev.BufferSize;
            isPlaying=1;
        elseif strcmp(data,'soundIsPlaying')
            %n=dev(zeros(1,14));
            send(q,isPlaying);
        elseif strcmp(data,'exit')
            send(q,'worker exits');
            break;
        elseif strcmp(data,'abort')
            if bufInd >= noabort
                isPlaying=0;                
            end
            send(q,isPlaying);
%             send(q,bufInd);
        elseif strcmp(data,'checkabort')
            send(q,bufInd)
        end
    end
    if isPlaying
        if bufInd+dev.BufferSize > size(toplay,1)
            endInd=size(toplay,1);
            isPlaying=0;
        else
            endInd=bufInd+dev.BufferSize-1;
        end
        dev(toplay(bufInd:endInd,:));
        bufInd=endInd+1;
    end
end

end