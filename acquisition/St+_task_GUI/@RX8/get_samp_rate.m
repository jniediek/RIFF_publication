function val=get_samp_rate(rx8)
actx_cntrl=get(rx8,'Controler');
val=invoke(actx_cntrl,'GetSFreq');
    