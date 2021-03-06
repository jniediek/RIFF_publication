function sig= change_sweep_param(sig,comp,varargin)
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
    comp_list_str=get(sig,'Comp_list_str');
    comp_name=get(comp,'Name');
    if ~isempty(strmatch(comp_name,comp_list_str))
        comp=change_sweep_param(comp,varargin{:});
        sig=set(sig,comp_name,comp);
    else
        sig_name=get(sig_name,'Name');
        treat_error([comp_name,' is not a ',sig_name,' property']);
    end
end
                            
            
            