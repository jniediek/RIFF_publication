function mAO_init_hardware
global mAO
% Init hardware connection
[u,s]=memory;
disp(u)
clear u s
disp('Starting SnR connection');
connect = AO_startConnection(mAO.DspMac,mAO.PcMac,-1);
[u,s]=memory;
disp(u)
clear u s
for j=1:100,
    pause(1);
    ret=AO_IsConnected;
    if ret==1
        disp('Successfuly connected to SnR')
        break;
    end
end
if j==100
    errordlg('Unable to connect to SnR','SnR Error','replace');
    return
end
% ### not storing any SnR data on the maestro in this version ###

% for ii=1:length(mAO.LFPChannels)
%     mAO.LFPdata{ii}=zeros(20000,1,'int16');
%     AO_AddBufferingChannel(mAO.LFPChannels(ii),mAO.LFPSampRate);
% end
% disp('after LFP')
% [u,s]=memory;
% disp(u)
% clear u s
% for ii=1:length(mAO.SEGChannels)
%     mAO.SEGdata{ii}=zeros(20000,1,'int16');
%     AO_AddBufferingChannel(mAO.SEGChannels(ii),mAO.SEGSampRate); 
% end 
% disp('after SEG')
% [u,s]=memory;
% disp(u)
% clear u s
% for ii=1:length(mAO.TRIGChannels)
%     mAO.TRIGdata{ii}=zeros(20000,1,'int16');
%     AO_AddBufferingChannel(mAO.TRIGChannels(ii),mAO.TRIGSampRate);
% end
% AO_ClearChannelData();
% disp('after TRIG')
% [u,s]=memory;
% disp(u)
% clear u s

