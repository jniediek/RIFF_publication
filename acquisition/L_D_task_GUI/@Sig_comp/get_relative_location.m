% GET_RELATIVE_LOCATION returns the relative location of the given value
% within the range of possible values of the given component.
% LOC=GET_RELATIVE_LOCATION(COMP,COMP_VAL) returns the relative location of
% the given value (COMP_VAL) within the range of possible values of the
% given component (COMP).

function loc=get_relative_location(comp,comp_val)
in_method=get(comp,'Input_method_flag');
switch in_method
    case 1%CONSTANT
        loc=1;
        
    case 2%SWEEP
      swp= get(comp,'Sweep');
      st=get(swp,'Sdata');
      et=get(swp,'Edata');
      if (st==et)
          loc=1;
          return;
      end
      no_reps=get_data(swp);
      sorted=sort(no_reps);
      loc=find(comp_val==sorted);
        
    case 3%SEQ_VALUES
        seq_vals=get(comp,'Seq_values');
        no_reps=unique(seq_vals);
        sorted=sort(no_reps);
        loc=find(comp_val==sorted);
end