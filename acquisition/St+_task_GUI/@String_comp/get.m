function val = get(s_comp,prop_name)
% GET Get s_comp property from the specified object
% and return the value. Property names are:
% Input_method, Static_value, Value_formula, Static_reps, Reps_formula, 
% Seq_values, Seq_values_str, Coord_index, Index_formula, Wrap, Fixed_num_data,
% Sweep, Seq_values, Seq_values_str, Input_method_flag, SIGNAL_MAX_TRIALS.
global STRING_METHODS;
STRING_METHODS={'STRING','SEQ_VALUES'};

if isa(prop_name,'char')
	switch prop_name
        case 'Name'
		    val = s_comp.name;  
		case 'Input_method'
		    val = s_comp.input_method;  
		case 'Static_value'
		    val = s_comp.static_value;
		case 'Static_reps' 
		    val=s_comp.static_reps;
		case 'Reps_formula'
		    val = s_comp.reps_formula;
        case {'Seq_values','Seq_values_str'}
		    val= s_comp.seq_values_str;   
		case 'Fixed_num_data'
		    val = s_comp.fixed_num_data;
		case 'Coord_index'
		    val = s_comp.coord_index;
		case 'Index_formula'
		    val = s_comp.index_formula;
		case 'Input_method_line'
		    val = s_comp.Input_method_line;
		case 'Constant_line'
		    val = s_comp.constant_line;
		case 'Wrap'
		    val = s_comp.wrap;
		case 'Input_method_flag'
            method=s_comp.input_method;
            val=strmatch(method,STRING_METHODS,'exact');
            if strcmp(method,'SEQ_VALUES')&&(val==2)
                val=3;
            end
        case  'SIGNAL_MAX_TRIALS'
            val=1000;
		otherwise
        	treat_error([prop_name,' is not a valid Sig_comp property']);
	end
else
    treat_error('The property input must be of type char');
end
