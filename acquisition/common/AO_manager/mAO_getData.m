function data=mAO_getData(ich)
global mAO
difftime=mAO.mt-mAO.PrevTrig;
num_samples=ceil(difftime*mAO.RX8sfreq);
t=(1:num_samples)*difftime/num_samples;
ft=find(mAO.LFPtime{ich}(1:mAO.LFPind(ich))<=mAO.PrevTrig,1,'last');
if isempty(ft)
    disp('mAO_getData: wrong start');
end
lt=find(mAO.LFPtime{ich}(1:mAO.LFPind(ich))>=mAO.mt,1,'first');
if isempty(lt)
    disp(['mAO_getData: Next Trig not reached, ich=', num2str(ich)]);
    lt=mAO.LFPind(ich);
else
    data=interp1(mAO.LFPtime{ich}(ft:lt),mAO.LFPbuffers{ich}(ft:lt),t+mAO.PrevTrig)/20/32768*5000;
end
