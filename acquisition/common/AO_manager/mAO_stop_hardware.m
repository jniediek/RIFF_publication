function mAO_stop_hardware
global mAO
r=AO_CloseConnection();
if r==0
    disp('closing SnR connection');
else
    disp('Problems in AO_CloseCOnnection');
end
mAO.LFPind=zeros(length(mAO.LFPChannels),1);
mAO.SEGind=zeros(length(mAO.SEGChannels),1);
mAO.TRIGind=zeros(length(mAO.TRIGChannels),1);
mAO.PrevTrig=NaN;
mAO.NextTrig=NaN;

