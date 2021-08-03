function def=get_default(env,index)
% GET_DEFAULT returns Envelope default value for the relevant component.
% DEF=GET_DEFAULT(ENV,INDEX) returns Envelope default value for the
% relevant component (according to the given index).

num_comps=get(env,'Num_of_comps');
index_opt=(1:1:num_comps);
if num_comps>0
	if (~isint(index) || ~any(index==index_opt))
        treat_error('Illegal index input for Envelope/get_comp_by_index');
	end
	comp_name=env.comp_list_str{index};
	upper_case_name=upper(comp_name);
	def_name=[upper_case_name,'_DEFAULT'];
	def=get(env.comp_list{index},def_name);
else
    treat_error('This Envelope contains no components');
end