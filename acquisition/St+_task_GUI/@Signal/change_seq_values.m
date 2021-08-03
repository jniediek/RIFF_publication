function sig= change_seq_values(sig,comp,arr,str_arr)
% CHANGE_SEQ_VALUES changes the sequenced-values of the given component.
% SIG=CHANGE_SEQ_VALUES(SIG,COMP,ARR,STR_ARR) changes the signal component's sequenced
% values to the given arr and it's string representation to str_arr.
% Returns the Signal after the change.

num_comps=get(sig,'Num_of_comps');
if num_comps>0
    if ~(isa(comp,'Sig_comp'))
         treat_error(['Wrong input for component parameter']);
     end
     comp_list_str=get(sig,'Comp_list_str');
     comp_name=get(comp,'Name');
    if ~isempty(strmatch(comp_name,comp_list_str))
		comp=set(comp, 'Seq_values',arr);
		comp=set(comp, 'Seq_values_str',str_arr);
		sig=set(sig,comp_name,comp);
    else
        sig_name=get(sig_name,'Name');
        treat_error([comp_name,' is not a ',sig_name,' property']);
    end
end