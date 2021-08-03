global ASIODev
InitializePsychSound
dev=PsychPortAudio('GetDevices');
k=cellfun(@isempty,strfind({dev.HostAudioAPIName},'ASIO'));
ASIODev=dev(~k).DeviceIndex;
tmp_points=zeros(192000/3,6);
tmp_routing=1:6;
samp_rate=192000;
t=1:length(tmp_points);
t=t(:);
Hz=2*pi/samp_rate;
tmp_points(1:1920,1)=1;
tmp_points(1920+(1:1920),2)=1;
tmp_points(:,3:6)=repmat(sin(Hz*t*1000),1,4);
h=pawavplay(tmp_points,samp_rate,0,tmp_routing);
PlayWav(h);
%%
CloseAllWav();