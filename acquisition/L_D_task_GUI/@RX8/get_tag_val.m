function val=get_tag_val(rx8,tag_name)
actx_cntrl=get(rx8,'Controler');
val=invoke(actx_cntrl,'GetTagVal',tag_name);
   