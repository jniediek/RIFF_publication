function data=mAO_getSpikes
global mAO
difftime=mAO.mt-mAO.PrevTrig;
num_samples=ceil(difftime*mAO.RX8sfreq);
t=(1:num_samples)*difftime/num_samples+mAO.PrevTrig;
data=zeros(mAO.num_elec,length(t));
for ic=1:length(mAO.SEGChannels)
    for is=1:mAO.SEGind(ic)
        if mAO.SEGbuffers{ic}(is)<mAO.mt
            tind=find(t<mAO.SEGbuffers{ic}(is),1,'last');
            if ~isempty(tind)
                data(ic,tind)=1;
            end
        end
    end
end

