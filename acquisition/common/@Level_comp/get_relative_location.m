function loc=get_relative_location(comp,comp_val)
% GET_RELATIVE_LOCATION returns the relative location of the given value
% within the range of possible values of the given component.
% LOC=GET_RELATIVE_LOCATION(COMP,COMP_VAL) returns the relative location of
% the given value (COMP_VAL) within the range of possible values of the
% given component (COMP).
% Since this is a Level_comp then the relative location is calculated
% top-down (for the values : 100, 90, 80  -- >  100(loc=1), 90(loc=2), 
% 80(loc=3)
in_method=get(comp,'Input_method_flag');

switch in_method
    case 1%CONSTANT
        loc=1;
        
    case 2%SWEEP
      swp= get(comp,'Sweep');
      data=get_data(swp);
      no_reps=unique(data);
      num_data=length(no_reps);
      sorted=sort(no_reps);
      tmp_loc=find(comp_val==sorted);
      loc=num_data-tmp_loc+1;
        
    case 3%SEQ_VALUES
        seq_vals=get(comp,'Seq_values');
        no_reps=unique(seq_vals);
        num_data=lenght(no_reps);
        sorted=sort(no_reps);
        tmp_loc=find(comp_val,sorted);
        loc=num_data-tmp_loc+1;
end