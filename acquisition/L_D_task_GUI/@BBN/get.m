function val= get(bbn,prop)
% GET Get BBN signal property from the specified object
% and return the value. Property names are:
% Name,  Signal, Level_comp, STime_comp, ETime_comp, Ramp_comp, Envelope_list,
% Num_of_env, Num_of_comps, Comp_list, Comp_list_str.

if isa(prop,'char')
	switch prop
    case 'Main_signal'
        val=bbn.Main_signal;
	otherwise
	    val=get(bbn.Main_signal,prop);
	end
else
    treat_error('The property input must be of type char');
end

