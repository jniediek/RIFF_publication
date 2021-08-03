%%%teting

Connect

AO_AddBufferingChannel(10000,1500)
AO_AddBufferingChannel(10001,1500)
AO_AddBufferingChannel(10002,1500)


arr=[10000,10001,10002]


[Result,pData,DataCapture,TS_FirstSample] = AO_GetAlignedData(arr,3)