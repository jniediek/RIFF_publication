function val = get(env,prop_name)
% GET Get Envelope property from the specified object
% and return the value. Property names are:
% Name, Signal, Num_of_comps, Comp_list, Comp_list_str,ENVELOPE_NAMES, ENVELOPE_NUMBER. 

if isa(prop_name,'char')
    index=strmatch(prop_name,env.comp_list_str,'exact');
    if ~isempty(index)
         val = env.comp_list{index};
   else
        switch prop_name
        case 'Signal'
            val = env.signal;
        case 'Num_of_comps'    
            val=length(env.comp_list);
        case 'Comp_list'
            val=env.comp_list;
        case 'Comp_list_str'
            val=env.comp_list_str;
        case 'ENVELOPE_NAMES'
            val= {'MTF','VRTP','FILE','NOTCH'};
        case 'ENVELOPE_NUMBER'
            names=get(env,'ENVELOPE_NAMES');
            val=length(names);
        otherwise
            val=get(env.signal,prop_name);
        end
end

else
    treat_error('The property input must be of type char');
end
