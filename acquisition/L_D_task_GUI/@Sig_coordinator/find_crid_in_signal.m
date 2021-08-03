function val=find_crid_in_signal(signal,crid)
% FIND_CRID_IN_SIGNAL search for a component in the signal with 
% the given coordination-index(crid).Returns 1 if found, 0 otherwise.
% VAL=FIND_CRID_IN_SIGNAL(SIGNAL,CRID)  search for  a  component in 
% the given signal with the given coordination-index(crid). Returns 1
% if found, 0 otherwise.

if (~isint(crid) || (crid<0))
  treat_error('Illegal CRID input  - must be a positive integer');
end

comp_list=get_comp_list(signal);
for k=1:length(comp_list)
    comp=comp_list{k};
   comp_crid=get(comp,'Coord_index');
   if (comp_crid==crid)
       val=1;
       return;
   end
end
   val=0;