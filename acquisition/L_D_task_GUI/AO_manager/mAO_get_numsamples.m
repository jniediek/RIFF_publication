function num_samples=mAO_get_numsamples
global mAO
mt=mAO.NextTrig;
for ic=1:length(mAO.LFPChannels)
    if mt>mAO.LFPtime{ic}(mAO.LFPind(ic))
        mt=mAO.LFPtime{ic}(mAO.LFPind(ic));
    end
end
mAO.mt=mt;
difftime=mAO.mt-mAO.PrevTrig;
num_samples=ceil(difftime*mAO.RX8sfreq);

