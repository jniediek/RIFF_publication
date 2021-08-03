function def=get_default(m_sig,index)
% GET_DEFAULT returns Main_signal default value for the relevant component.
% DEF=GET_DEFAULT(M_SIG,INDEX) returns Main_signal default value for the relevant component.
% according to the given index.

num_comps=get(m_sig,'Num_of_comps');
index_opt=(1:1:num_comps);
if (~isint(index) || ~any(index==index_opt))
    treat_error('Illegal index input for Main_signal/get_comp_by_index');
end
comp_name=m_sig.comp_list_str{index};
upper_case_name=upper(comp_name);
def_name=[upper_case_name,'_DEFAULT'];
def=get(m_sig.comp_list{index},def_name);
