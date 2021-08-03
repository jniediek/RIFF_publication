function comp= change_sweep_param(comp,varargin)
% change_sweep_param(sig_comp, field_name1, val1, field_name2, val2...)
% changes sweep's fields to the given values.
% Sweep fields  are: Sdata, Sdata_formula, Edata, Edata_formula, Num_data, 
% Num_data_formula, Reps, Reps_formula, Mode, Step.

param_argin = varargin;
while length(param_argin) >= 2,
param = param_argin{1};
val = param_argin{2};
param_argin = param_argin(3:end);
	switch param
	case 'Sdata'
        if (is_legal_phase(comp,val))
            comp.Sig_comp=change_sweep_param(comp.Sig_comp,'Sdata',val);
        else
		    treat_error('The given value is not a legal Phase'); 
		end
	case 'Edata'
	    if (is_legal_phase(comp,val))
            comp.Sig_comp=change_sweep_param(comp.Sig_comp,'Edata',val); 
       else
		    treat_error('The given value is not a legal Phase'); 
		end
	otherwise
	   comp.Sig_comp=change_sweep_param(comp.Sig_comp,param,val);
	end
end
        

