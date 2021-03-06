function   [sig_comp,err_msg]=update_final_swp_values(component,index,def_arr,var_arr)
%  UPDATE_FINAL_SWP_VALUES calculates the expressions of the Sweep
%  parameter according to the values of the varaibles that appear in the expression. 
%  [SIG_COMP,ERR_MSG]=UPDATE_FINAL_SEQ_VALUES(COMPONENT,INDEX,DEF_ARR,VAR_ARR)
%  calculates the expressions of the relevent Sweep parameter (according to index. 
%  If index=1 then the relevant parameter  is sdata , if 2->edata, if 3-> num_data, 
%  if 4->reps) of the given component.
%  It calculates by  replacing varaibles with their values. If the final value
%  that was calculated is not legal, then ERROR will hold the relevant error
%  message. If the value is legal then the Sweep parameter of this
%  component is updated and the new component is returned.
%  The expressions can contains 2 types of varaibles: dynamic type (varaibles
%  that are defined in DEF_ARR) or non-dynamic (varaibles that are defined
%  in VAR_ARR).
%  For example: suppose that this signal component holds a Sweep with
%  start data = A*2+BF-600 and that at the time of calculation : A=500;  BF=1000; 
%  Then UPDATE_FINAL_SEQ_VALUES will update start data to be:  1400
%  If, on the other hand, this signal component holds a Sweep with
%  start data = C*2+BF-600 and that at the time of calculation : C is not 
%  defined in var_arr and  BF=1000; . Then ERR_MSG will hold an error report since C 
%  is not a legal expression and the component will not be updated.

index_opt=[1 2 3 4];
if (~isa(index,'double') || ~(length(index)==1) || ~any(index==index_opt))
    error('The given index must be one of the following : 1, 2, 3, 4.');
end

prop_names={'Sdata','Edata','Num_data','Reps'};
field_checked={'Static_value','Static_value','Num_data','Reps'};  
field_name=prop_names{index};
formula=[field_name,'_formula'];
formula_str=get_sweep_param(component,formula);%holds the expressions
s=size(def_arr);
err_msg='';

for q=1:s(2)
		rep=num2str(def_arr{2,q});
		formula_str=strrep(formula_str,def_arr{1,q},rep);
end%for
if (~isempty(var_arr))
		s=size(var_arr);
		for q=1:s(2)
				rep=num2str(var_arr{2,q});
				formula_str=strrep(formula_str,var_arr{1,q},rep);
		end%for
end%if

tf = isletter(formula_str);
if any(tf)
    err_msg=['An undefined varaible exists in ',formula_str];
else
    [valid_flag,err_msg,is_formula]=check_if_legal(component,field_checked{index},formula_str,def_arr,var_arr);
end

if(isempty(err_msg))
    eval(['num=',formula_str,';']);
    sig_comp=change_sweep_param(component,field_name,num);
else
    sig_comp=component;
end
