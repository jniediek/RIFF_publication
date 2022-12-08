function mAO=AO_manager(handles)
global LFPSampRate;
mAO.num_elec=handles.num_elec;
mAO.LFPChannels=handles.LFPChannels;
mAO.LFPSampRate=handles.LFPSampRate;
mAO.SEGChannels=handles.SEGChannels;
mAO.SEGSampRate=handles.SEGSampRate;
mAO.TRIGChannels=handles.TRIGChannels;
mAO.TRIGSampRate=handles.TRIGSampRate;
mAO.LFPdata=cell(length(mAO.LFPChannels),1);
mAO.SEGdata=cell(length(mAO.SEGChannels),1);
mAO.TRIGdata=cell(length(mAO.TRIGChannels),1);
mAO.LFPbuffers=cell(length(mAO.LFPChannels),1);
mAO.LFPtime=cell(length(mAO.LFPChannels),1);
for ii=1:length(mAO.LFPbuffers)
    mAO.LFPbuffers{ii}=zeros(ceil(12*mAO.LFPSampRate),1);
    mAO.LFPtime{ii}=zeros(size(mAO.LFPbuffers{ii}));
end
mAO.SEGbuffers=cell(length(mAO.SEGChannels),1);
for ii=1:length(mAO.SEGChannels)
    mAO.SEGbuffers{ii}=zeros(ceil(mAO.SEGSampRate),1);
end
mAO.TRIGbuffers=zeros(100,length(mAO.TRIGChannels));
mAO.LFPind=zeros(length(mAO.LFPChannels),1);
mAO.SEGind=zeros(length(mAO.SEGChannels),1);
mAO.TRIGind=zeros(length(mAO.TRIGChannels),1);
mAO.PrevTrig=NaN;
mAO.NextTrig=NaN;
mAO.FirstTrig=0;
mAO.mt=0;
mAO.DspMac='c8:a0:30:27:21:8f';
mAO.PcMac='00:11:6B:4F:9B:A6';
mAO.RX8sfreq=LFPSampRate;
%mAO=class(mAO,'AO_manager');
