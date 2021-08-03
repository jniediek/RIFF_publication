function val = get(gap,prop_name)
% GET Get GAP property from the specified object
% and return the value. Property names are:
% Name, Signal, ETime_comp, STime_comp, Ramp_comp, Comp_list, 
% Num_of_comps, Comp_list_str.

if isa(prop_name,'char')
      switch prop_name
        case 'Envelope'
            val=gap.Envelope;
		otherwise
           val=get(gap.Envelope,prop_name);
        end
   else
    treat_error('The property input must be of type char');
end 