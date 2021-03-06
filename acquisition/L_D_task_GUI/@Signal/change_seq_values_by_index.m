function sig= change_seq_values_by_index(sig,comp_index,arr,str_arr)
% CHANGE_SEQ_VALUES changes the sequenced-values of the given component.
% SIG=CHANGE_SEQ_VALUES(SIG,COMP,ARR,STR_ARR) changes the signal component's sequenced
% values to the given arr and it's string representation to str_arr.
% Returns the Signal after the change.

num_comps=get(sig,'Num_of_comps');
if num_comps<comp_index
    treat_error(['Wrong input for component parameter']);
end
comp=get_comp_by_index(sig,comp_index);
comp=set(comp, 'Seq_values',arr);
comp=set(comp, 'Seq_values_str',str_arr);
sig=set_comp_by_index(sig,comp,comp_index);
