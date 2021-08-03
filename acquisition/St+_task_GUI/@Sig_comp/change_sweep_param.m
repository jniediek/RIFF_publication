function sig_comp= change_sweep_param(sig_comp,varargin)
% change_sweep_param(sig_comp, field_name1, val1, field_name2, val2...)
% changes sweep's fields to the given values.
% Sweep fields  are: Sdata, Sdata_formula, Edata, Edata_formula, Num_data, 
% Num_data_formula, Reps, Reps_formula, Mode, Step.
    sdata_flg=0;
    edata_flg=0;
    step_flg=0;
	param_argin = varargin;
	while length(param_argin) >= 2,
	param = param_argin{1};
	val = param_argin{2};
	param_argin = param_argin(3:end);
        switch param
            case {'Sdata_formula','Edata_formula','Num_data_formula','Reps_formula'}
                if (~isa(val,'char'))
                    treat_error('The value must be of type char');
                end
        end
    
		switch param
		case 'Sdata'
          sig_comp.Sweep=set(sig_comp.Sweep,'Sdata',val);
		case 'Sdata_formula'
		    sig_comp.Sweep=set(sig_comp.Sweep,'Sdata_formula',val);  
		case 'Edata'
             sig_comp.Sweep=set(sig_comp.Sweep,'Edata',val);
		case 'Edata_formula'
		    sig_comp.Sweep=set(sig_comp.Sweep,'Edata_formula',val);
		case 'Num_data'
		    sig_comp.Sweep=set(sig_comp.Sweep,'Num_data',val);
		    r=get_sweep_param(sig_comp,'Reps');
		    sig_comp.fixed_num_data=val*r;
		case 'Num_data_formula'
		    sig_comp.Sweep=set(sig_comp.Sweep,'Num_data_formula',val);
		case 'Reps'
		    sig_comp.Sweep=set(sig_comp.Sweep,'Reps',val);
		    n=get_sweep_param(sig_comp,'Num_data');
		    sig_comp.fixed_num_data=val*n;
		case 'Reps_formula'
		    sig_comp.Sweep=set(sig_comp.Sweep,'Reps_formula',val);
		case 'Mode'
		    sig_comp.Sweep=set(sig_comp.Sweep,'Mode',val);
		case 'Step'
             step_flg=1;
            sig_comp.Sweep=set(sig_comp.Sweep,'Step',val);
		otherwise
		    treat_error([param 'is not a valid Sweep parameter']);
		end
	end

            

