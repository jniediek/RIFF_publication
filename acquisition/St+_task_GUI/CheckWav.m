function status=CheckWav(pahandle)
si=PsychPortAudio('GetStatus',pahandle);
status=si.Active;


