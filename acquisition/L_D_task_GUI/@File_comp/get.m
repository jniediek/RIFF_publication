function val = get(comp,prop_name)
% GET Get STIME_comp property from the specified object
% and return the value. Property names are:
% Name,Sig_comp,Swp_on,Seq_on,Static_value,Sweep,Seq_values.
global FILE_COMP_DEFAULT;

if isa(prop_name,'char')
    switch prop_name
        case 'Sig_comp'
            val = comp.String_comp;
        case 'Name'
            val = comp.name;
        case  'FILE_COMP_DEFAULT'
            val=FILE_COMP_DEFAULT;
        case 'Basedir'
            val=comp.basedir;
        otherwise
            val=get(comp.String_comp,prop_name);
    end

else
    treat_error('The property input must be of type char');
end