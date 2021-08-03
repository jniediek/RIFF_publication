function pahandle=pawavplay(tmp_points,samp_rate,nn,tmp_routing)
global ASIODev
pahandle=PsychPortAudio('Open', ASIODev, [], nn, samp_rate, 6);
toplay=zeros(length(tmp_points),6);
toplay(:,tmp_routing)=tmp_points;
PsychPortAudio('FillBuffer', pahandle, toplay');
