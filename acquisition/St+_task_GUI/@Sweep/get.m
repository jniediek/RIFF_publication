function val = get(swp,prop_name)
% GET Get Sweep property from the specified object
% and return the value. Property names are: Sdata, Sdata_formula
% Edata, Edata_formula, Num_data, Num_data_formula, Reps, Reps_formula,
% Mode, Step,Seq_length.

switch prop_name
	case 'Sdata'
	    val = swp.sdata;
	case 'Sdata_formula'
	    val = swp.sdata_formula;
	case 'Edata'
	    val = swp.edata;
	case 'Edata_formula'
	    val = swp.edata_formula;
	case 'Num_data'
	    val = swp.num_data;
	case 'Num_data_formula'
	    val = swp.num_data_formula;
	case 'Reps'
	    val = swp.reps;
	case 'Reps_formula'
	    val = swp.reps_formula;
	case 'Mode'
	    val = swp.mode;
	case 'Step'
	    val = swp.step;
	case 'Seq_length'
	    val = swp.seq_length;
    case 'SWEEP_MAX_TRIALS'
        val=1000;
	otherwise
	    error([prop_name,' Is not a valid Sweep property']);
end
 