function val=get_tag_size(rx8,tag)
actx_cntrl=get(rx8,'Controler');
val=invoke(actx_cntrl,'GetTagSize',tag);
   