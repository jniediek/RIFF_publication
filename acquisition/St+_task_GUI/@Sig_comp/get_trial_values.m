function values = get_trial_values(s_comp,varargin)
% GET_TRIAL_VALUES(S_COMP) returns an array of values that would be generated for 
% this Signal component (s_comp) according to it's internal state.
% values = GET_TRIAL_VALUES(S_COMP,RANDOM_INDICES_ARRAY) returns an array of values
% for the given Signal component which it's input method is SWEEP with
% mode==RND. The array of values will be  randomly chosen according to the
% given RANDOM_INDICES_ARRAY.

in_method_f=get(s_comp,'Input_method_flag');
if (~(in_method_f==2) && ~(nargin==1))
    treat_error('Ilegal number of arguments for get_trial_values');
else
	switch in_method_f
		case 1
			stat_value=get(s_comp,'Static_value');
			reps_value=get(s_comp,'Static_reps');
			values= linspace(stat_value,stat_value,reps_value);
        
		case 2
			swp=get(s_comp,'Sweep');
			if( strcmp(get(swp,'Mode'),'SEQ')==1)
                if (~(nargin==1))
                    treat_error('Ilegal number of arguments for get_trial_values');
                end
			    values = get_data_reps(swp);
			elseif( strcmp(get(swp,'Mode'),'RND')==1)
				if ~isempty(varargin)
				    values = get_data_mode(swp,varargin{1});
				else
				    num_data=get(s_comp,'Fixed_num_data');
				    rand_indices=randperm(num_data);
				    values = get_data_mode(swp,rand_indices);
				end
			end
        
		case 3
		    values=get(s_comp,'Seq_values');
	end
end