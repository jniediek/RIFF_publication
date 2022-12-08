function atten=get_atten_display(pa5)
actx_cntrl=get(pa5,'Controler');
dev_num=get(pa5,'Device_num');
atten=invoke(actx_cntrl,'GetAtten');
   
