function sig= change_sweep_param_by_index(sig,comp,comp_index,varargin)
% CHANGE_SWEEP_PARAM changes sweep's fields of the given component to the given
% values and returns the updated signal.
% sig=CHANGE_SWEEP_PARAM(SIG,COMP,FIELD_NAME1,VAL1,FIELD_NAME2,VAL2,...)
% changes sweep's fields of the given component to the given values and
% returns the updated signal.
% Sweep fields  are: Sdata, Sdata_formula, Edata, Edata_formula,
% Num_data, Num_data_formula, Reps_formula, Reps, Mode, Step

num_comps=get(sig,'Num_of_comps');
if num_comps>0
    if ~(isa(comp,'Sig_comp'))
        treat_error(['Wrong input for component parameter']);
    end
    if comp_index>num_comps
        treat_error('Wrong index');
    end
    comp=change_sweep_param(comp,varargin{:});
    sig=set_comp_by_index(sig,comp,comp_index);
end


