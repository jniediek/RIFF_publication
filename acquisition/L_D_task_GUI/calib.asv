HDSPInInd=6;
HDSPOutInd=7;
ftab=exp(linspace(log(1000),log(64000),51));
Hz=2*pi/192000;
for ii=1:length(ftab)
    sig=sin(ftab(ii)*Hz*(1:192000));
    win=[linspace(0,1,1920) ones(1,192000-1920*2) linspace(1,0,1920)];
    sig=sig.*win/10;
    y=audioplayer(sig,192000,24,HDSPOutInd);
    samp=audiorecorder(192000,24,2,HDSPInInd);
    record(samp);
    play(y)
    while isplaying(y)
        disp(ftab(ii))
    end
    stop(samp);
    dat=getaudiodata(samp);
    pwelch(dat(:,1),[],[],[],192);
    title(ftab(ii))
    drawnow
    clear y samp
    acalib(ii).freq=ftab(ii);
    acalib(ii).samp=dat;
    acalib(ii).out=sig;
end
save('c:\maestro_results\calib','acalib');