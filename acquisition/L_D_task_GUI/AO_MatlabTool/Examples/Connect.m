'tesitning is AO_StartConnection function';
DSPMAC='3c:2d:b7:41:17:80';%this have to be the mac address of your system (dsp)

PCMac='3c:2d:55:12:34:FE';%mac address of the pc which run this matlab
Activeadapte=-1;          %the number of the connection you are using 
   	                   %-1 tell will search for the network card

%this function will start the conection between the matlab and the system
retStartConnection=AO_startConnection(DSPMAC,PCMac,Activeadapte);
'Start Connection'


for j=1:100,
    pause(1);
    %break;
   ret=AO_IsConnected;
    if ret==1
        'The System is Connected'
        break;
    end
end