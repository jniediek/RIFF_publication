function val = get_sweep_param(s_comp,prop_name)
% GET Get s_comp's sweep property from the specified signal component
% and return the value. 
% val = get_sweep_param(s_comp,prop_name) returns s_comp prop_name.
% Property names are:
% Sdata, Sdata_formula, Edata, Edata_formula, Num_data, Num_data_formula,
% Reps, Reps_formula, Mode, Step, Seq_length

if isa(prop_name,'char')
	switch prop_name
	case 'Sdata'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Sdata');
	case 'Sdata_formula'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Sdata_formula');
	case 'Edata'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Edata');
	case 'Edata_formula'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Edata_formula');
	case 'Num_data'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Num_data');
	case 'Num_data_formula'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Num_data_formula');
	case 'Reps'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Reps');
	case 'Reps_formula'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Reps_formula');
	case 'Mode'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Mode');
	case 'Step'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Step');
	case 'Seq_length'
        swp=get(s_comp,'Sweep');
	    val = get(swp,'Seq_length');
	otherwise
	    treat_error([prop_name,' is not a valid SWEEP property']);
	end
else
    treat_error('The property input must be of type char');
end
