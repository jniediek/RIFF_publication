for ind=1:1
%/
[Result,pData,DataCapture] =AO_GetChannelData(10256);
if(DataCapture~=0)
    DataCapture=0;
spk = pData(1:DataCapture);
spk=double(spk);
spkBlocks = reshape(spk,spk(1),length(spk)/spk(1));
spkTimeStamps = spkBlocks(5:6,:);
blockNum=1;
firstTSSpk=bin2dec([dec2bin(mod(double(spkTimeStamps(2,blockNum)),2^16),16) dec2bin(mod(double(spkTimeStamps(1,blockNum)),2^16),16)]);

blockNum=size(spkBlocks);
blockNum=blockNum(2);
diff=firstTSSpk-EndTSSpk;
EndTSSpk=bin2dec([dec2bin(mod(double(spkTimeStamps(2,blockNum)),2^16),16) dec2bin(mod(double(spkTimeStamps(1,blockNum)),2^16),16)]);
end
%%/

[Result1,pData1,DataCapture1] =AO_GetChannelData(10128);
if(DataCapture1~=0)
    
spk1 = pData1(1:DataCapture1);
spk1=double(spk1);
spkBlocks1 = reshape(spk1,spk1(1),length(spk1)/spk1(1));
spkTimeStamps1 = spkBlocks1(5:6,:);
blockNum=1;
firstTSSEG=bin2dec([dec2bin(mod(double(spkTimeStamps1(2,blockNum)),2^16),16) dec2bin(mod(double(spkTimeStamps1(1,blockNum)),2^16),16)]);;
blockNum=size(spkBlocks1);
blockNum=blockNum(2);
diff=firstTSSEG-EndTSSEG;
EndTSSEG=bin2dec([dec2bin(mod(double(spkTimeStamps1(2,blockNum)),2^16),16) dec2bin(mod(double(spkTimeStamps1(1,blockNum)),2^16),16)]);

EndTSSpk;
EndTSSEG;

end
if (DataCapture1~=0 & DataCapture~=0)
    diffSegspkEND=double(EndTSSEG)-double(EndTSSpk*2)
    diffSegspkStart=double(firstTSSEG)-double(firstTSSpk*2)
end
tic 
while toc<0.1
end    
end