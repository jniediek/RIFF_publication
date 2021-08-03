function val=check_if_all_comps_wrap(sig_c)
comp_list=get_comp_list(sig_c);
for k=1:length(comp_list);
    comp=comp_list{k};
   comp_wrap=get(comp,'Wrap');
   if (~comp_wrap)
       val=0;
       return;
   end
end
val=1;