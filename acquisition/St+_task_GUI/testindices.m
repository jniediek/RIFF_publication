RP=actxcontrol('RPco.x',[5 5 26 26]);% starts the RP activeX control in MATLAB

invoke(RP,'ConnectRP2','GB',1); %connects an RP2 via USB or GB

e2=invoke(RP,'ClearCOF'); %Clears the Buffers and COF files on that RP

ee=invoke(RP,'LoadCOF','c:\ella\tdt\rpvds\testindices.rcx'); % Loads circuit('c:\example')

invoke(RP,'Run'); %Starts Circuit

Status=double(invoke(RP,'GetStatus'));% returns a value (7=circuit loaded and running) 
%%
nn=zeros(1,100000);
dd=zeros(1,100000);
for ii=1:length(nn)
    vv=invoke(RP,'GetTagVal','SpTimeIndex1_1');
    %disp(dec2hex(vv));
    tmp=uint32(vv);
    numspikes=bitand(tmp,32767);
    numtimes=bitand(bitshift(tmp,-16),32767);
    %disp([numspikes numtimes double(numspikes)-double(numtimes)])
    nn(ii)=numspikes;
    dd(ii)=numspikes-numtimes;
end
figure(100);
plot(nn,dd,'x');
