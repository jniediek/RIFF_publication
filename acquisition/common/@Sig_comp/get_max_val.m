function maximum = get_max_val(s_comp)
% GET_MAX_VAL returns the maximal value for this component
in_method_f=get(s_comp,'Input_method_flag');

	switch in_method_f
		case 1
			maximum=get(s_comp,'Static_value');
        
		case 2
			swp=get(s_comp,'Sweep');
			st=get(swp,'Sdata');
            et=get(swp,'Edata');
            num_data=get(swp,'Num_data');
            if num_data==1
               maximum=st;
            else
                if st<et
                    maximum=et;
                else
                    maximum=st;
                end
            end
            
		case 3
		    values=get(s_comp,'Seq_values');
            maximum=max(values);
    end