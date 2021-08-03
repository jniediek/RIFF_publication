function minimum = get_min_val(s_comp)
% GET_MIN_VAL returns the minimal value for this component
in_method_f=get(s_comp,'Input_method_flag');

	switch in_method_f
		case 1
			minimum=get(s_comp,'Static_value');
        
		case 2
			swp=get(s_comp,'Sweep');
			st=get(swp,'Sdata');
            et=get(swp,'Edata');
            num_data=get(swp,'Num_data');
            if num_data==1
               minimum=st;
            else
                if st<et
                    minimum=st;
                else
                    minimum=et;
                end
            end
            
		case 3
		    values=get(s_comp,'Seq_values');
            minimum=min(values);
    end
