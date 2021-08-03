function val = get(comp,prop_name)
% GET Get Level_comp property from the specified object
% and return the value. Property names are:
% Sig_comp,Swp_on,Seq_on,Static_value,Sweep,Seq_values.
global LEVEL_COMP_DEFAULT;
global MAX_LEVEL;

if isa(prop_name,'char')
switch prop_name
 case 'Sig_comp'
    val = comp.Sig_comp; 
case 'Name'
    val = comp.name;
case  'LEVEL_COMP_DEFAULT'
    val=LEVEL_COMP_DEFAULT;
case  'MAX_LEVEL'
    Level_comp;
    val=MAX_LEVEL;
otherwise
    val=get(comp.Sig_comp,prop_name);
end

else
    treat_error('The property input must be of type char');
end