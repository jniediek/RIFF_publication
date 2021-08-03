function val = get_comp_by_index(env,comp_index)
% GET_COMP_BY_INDEX gets env's component according to the specified index.
% VAL=GET_COMP_BY_INDEX(ENV,COMP_INDEX) Gets The given Envelope
% component according to the specified component index.
% Index Range may include :1,2,3,or 4 (as the maximum number of Envelope components).

num_comps=get(env,'Num_of_comps');
if num_comps>0
	index_opt=(1:1:num_comps);
	if (~isint(comp_index) ||  ~any(comp_index==index_opt))
        treat_error('Illegal index input for Envelope/get_comp_by_index');
	end
	val = env.comp_list{comp_index};
else
    treat_error('This Envelope contains no components');
end
