function val = get_comp_by_index(m_sig,comp_index)
% GET_COMP_BY_INDEX Gets component according to the specified index.
% VAL=GET_COMP_BY_INDEX(M_SIG,COMP_INDEX) Gets The given Main_Signal
% component according to the specified component index.
% Index can be 1,2,3,or 4 (as the number of Main_signalcomponents)
% index=1 returns Level component, index=2 returns Start-time component, 
% index=3 returns End-time component, index=4 returns Ramp-length component.

num_comps=get(m_sig,'Num_of_comps');
index_opt=(1:1:num_comps);
if (~isint(comp_index) ||  ~any(comp_index==index_opt))
    treat_error('Illegal index input for Main_signal/get_comp_by_index');
end
list=get(m_sig,'Comp_list');
val = list{comp_index};
