function val = get(m_sig,prop_name)
% GET Get Main_signal property from the specified object
% and return the value. Property names are:
% Name, Signal, Level_comp, STime_comp, ETime_comp, Ramp_comp, Envelope_list,
% Num_of_env, Comp_list, Comp_list_str.

if isa(prop_name,'char')
    index=strmatch(prop_name,m_sig.comp_list_str,'exact');
    if ~isempty(index)
         val = m_sig.comp_list{index};
   else
		switch prop_name
		case 'Signal'
            val = m_sig.Signal;
         case 'Envelope_list'
            val = m_sig.envelope_list;
        case 'Num_of_env'
            val = m_sig.num_of_env;  
        case 'Num_of_comps'    
            val=length(m_sig.comp_list);
        case 'Comp_list'
            val=m_sig.comp_list;
         case 'Comp_list_str'
            val=m_sig.comp_list_str;
		otherwise
            val=get(m_sig.Signal,prop_name);
		end
    end
else
    treat_error('The property input must be of type char');
end