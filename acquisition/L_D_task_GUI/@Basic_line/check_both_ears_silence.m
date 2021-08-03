function both=check_both_ears_silence(line)
rear=get(line,'Right_ear');
lear=get(line,'Left_ear');
if (strcmp(rear,'SILENCE') && strcmp(lear,'SILENCE'))
	both=1;
else
    both=0;
end