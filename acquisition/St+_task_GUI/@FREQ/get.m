function val = get(freq,prop_name)
% GET Get FREQ property from the specified object
% and return the value. Property names are:
% Name, Signal, Level_comp, STime_comp, ETime_comp, Ramp_comp, Envelope_list,
% Num_of_env, Comp_list, Num_of_comps, Comp_list_str.

if isa(prop_name,'char')
    switch prop_name
        case 'Main_signal'
            val=freq.Main_signal;
		otherwise
           val=get(freq.Main_signal,prop_name);
    end
else
    treat_error('The property input must be of type char');
end