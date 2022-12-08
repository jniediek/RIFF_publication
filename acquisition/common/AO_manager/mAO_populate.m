function errorflag=mAO_populate(lastflag)
global mAO
errorflag=0;
SWTRIG=zeros(length(mAO.TRIGChannels),1);
while mAO.TRIGind(1)<2
    for ic=1:length(mAO.TRIGChannels)
        [Result,SWTRIG(ic)]=MexFileEthernetStandAlone(24,mAO.TRIGChannels(ic),mAO.TRIGdata{ic});
    end
    for ic=1:length(mAO.TRIGChannels)
        pos=1;
        arraydata=mAO.TRIGdata{ic};
        while pos<SWTRIG(ic)
            if arraydata(pos+3)==1
                %tts=bin2dec([dec2bin(mod(double(arraydata(pos+5)),2^16),16) dec2bin(mod(double(arraydata(pos+4)),2^16),16)]);
                t4=double(arraydata(pos+4));
                if t4<0
                    t4=65536+t4;
                end
                t5=double(arraydata(pos+5));
                if t5<0
                    t5=65536+t5;
                end
                tts=t5*65536+t4;
                mAO.TRIGbuffers(mAO.TRIGind(ic)+1,ic)=tts;
                mAO.TRIGind(ic)=mAO.TRIGind(ic)+1;
            end
            pos=pos+arraydata(pos);
        end
    end
    if lastflag
        break;
    end
end
ictrig=1;
if isnan(mAO.PrevTrig)
    mAO.NextTrig=mAO.TRIGbuffers(1,ictrig)/mAO.TRIGSampRate;
    mAO.FirstTrig=mAO.NextTrig;
    mAO.NextTrig=0;
end
mAO.mt=mAO.NextTrig-mAO.PrevTrig;
mAO.PrevTrig=mAO.NextTrig;
if lastflag
    mAO.NextTrig=mAO.PrevTrig+mAO.mt;
else
    mAO.NextTrig=mAO.TRIGbuffers(2,ictrig)/mAO.TRIGSampRate-mAO.FirstTrig;
    mAO.TRIGbuffers(1:mAO.TRIGind(ictrig)-1,:)=mAO.TRIGbuffers(2:mAO.TRIGind(ictrig),:);
    mAO.TRIGind=mAO.TRIGind-1;
end
%%
SW=zeros(length(mAO.LFPChannels),1);
SWSEG=zeros(length(mAO.SEGChannels),1);
for ic=1:length(mAO.LFPChannels)
    [Result,SW(ic)]=MexFileEthernetStandAlone(24,mAO.LFPChannels(ic),mAO.LFPdata{ic});
end
for ic=1:length(mAO.SEGChannels)
    [Result,SWSEG(ic)]=MexFileEthernetStandAlone(24,mAO.SEGChannels(ic),mAO.SEGdata{ic});
end
%%
for ic=1:length(mAO.LFPChannels)
    pos=1;
    arraydata=mAO.LFPdata{ic};
    while pos<SW(ic)
        skip=arraydata(pos);
        %tts=bin2dec([dec2bin(mod(double(arraydata(pos+5)),2^16),16) dec2bin(mod(double(arraydata(pos+4)),2^16),16)]);
        t4=double(arraydata(pos+4));
        if t4<0
            t4=65536+t4;
        end
        t5=double(arraydata(pos+5));
        if t5<0
            t5=65536+t5;
        end
        tts=t5*65536+t4;
        samples=arraydata(pos+(7:(skip-1)));
        len=length(samples);
        mAO.LFPbuffers{ic}(mAO.LFPind(ic)+(1:len))=samples;
        mAO.LFPtime{ic}(mAO.LFPind(ic)+(1:len))=(tts-1+(1:len))/mAO.LFPSampRate-mAO.FirstTrig;
        mAO.LFPind(ic)=mAO.LFPind(ic)+len;
        pos=pos+skip;
    end
    pind=find(mAO.LFPtime{ic}(1:mAO.LFPind(ic))<mAO.PrevTrig,1,'last');
    if ~isempty(pind)
        mAO.LFPbuffers{ic}(1:mAO.LFPind(ic)-pind+1)=mAO.LFPbuffers{ic}(pind:mAO.LFPind(ic));
        mAO.LFPtime{ic}(1:mAO.LFPind(ic)-pind+1)=mAO.LFPtime{ic}(pind:mAO.LFPind(ic));
        mAO.LFPind(ic)=mAO.LFPind(ic)-pind+1;
    end
end
for ic=1:length(mAO.SEGChannels)
    pos=1;
    arraydata=mAO.SEGdata{ic};
    while pos<SWSEG(ic)
        %tts=bin2dec([dec2bin(mod(double(arraydata(pos+5)),2^16),16) dec2bin(mod(double(arraydata(pos+4)),2^16),16)]);
        t4=double(arraydata(pos+4));
        if t4<0
            t4=65536+t4;
        end
        t5=double(arraydata(pos+5));
        if t5<0
            t5=65536+t5;
        end
        tts=t5*65536+t4;
        try
            mAO.SEGbuffers{ic}(mAO.SEGind(ic)+1)=tts/mAO.SEGSampRate-mAO.FirstTrig;
        catch err
            errorflag=1;
            u=memory;
            disp([num2str(numel(mAO.SEGbuffers)*mAO.num_elec) ' ' num2str(u.MaxPossibleArrayBytes) ' Fragmented memory']);
            disp(err)
            return;
        end
        mAO.SEGind(ic)=mAO.SEGind(ic)+1;
        pos=pos+arraydata(pos);
    end
    pind=find(mAO.SEGbuffers{ic}(1:mAO.SEGind(ic))<mAO.PrevTrig,1,'last');
    if ~isempty(pind)
        mAO.SEGbuffers{ic}(1:mAO.SEGind(ic)-pind+1)=mAO.SEGbuffers{ic}(pind:mAO.SEGind(ic));
        mAO.SEGind(ic)=mAO.SEGind(ic)-pind+1;
    end
end

