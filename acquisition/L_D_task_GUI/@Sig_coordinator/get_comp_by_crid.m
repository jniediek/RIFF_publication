function comp_val=get_comp_by_crid(signal,crid)
% GET_COMP_BY_CRID search for the first component in the signal with 
% the given coordination-index(crid) and returns that component.


if (~isint(crid) || (crid<0))
  treat_error('Illegal CRID input  - must be a positive integer');
end

comp={};
comp_list=get_comp_list(signal);
for k=1:length(comp_list)
   comp=comp_list{k};
   comp_crid=get(comp,'Coord_index');
  wrap=get(comp,'Wrap');
  if (~wrap &&(comp_crid==crid))
       break;
  end
end%for
comp_val=comp;