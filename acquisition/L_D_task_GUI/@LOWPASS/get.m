function val = get(new_env,prop_name)
% GET Get NEW_ENV property from the specified object
% and return the value. Property names are:
% Name, Signal, Freq_comp, Phase_comp, Comp_list, 
% Num_of_comps, Comp_list_str.

if isa(prop_name,'char')
      switch prop_name
        case 'Envelope'
            val=new_env.Envelope;
		otherwise
           val=get(new_env.Envelope,prop_name);
        end
   else
    treat_error('The property input must be of type char');
end 