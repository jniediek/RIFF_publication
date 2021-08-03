function val = get(comp,prop_name)
% GET Get Trial_dur_comp property from the specified object
% and return the value. Property names are:
% Sig_comp,Swp_on,Seq_on,Static_value,Sweep,Seq_values.
global TRIAL_DUR_COMP_DEFAULT;

if isa(prop_name,'char')
    switch prop_name
     case 'Sig_comp'
        val = comp.Sig_comp; 
	case 'Name'
        val = comp.name;
    case  'TRIAL_DUR_COMP_DEFAULT'
        val=TRIAL_DUR_COMP_DEFAULT;
        otherwise
        val=get(comp.Sig_comp,prop_name);
	end

else
    treat_error('The property input must be of type char');
end