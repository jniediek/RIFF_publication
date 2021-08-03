function values= get_trial_values(s_comp,varargin)
% GET_TRIAL_VALUES(S_COMP) returns an array of values that would be generated for 
% this String component (s_comp) according to it's internal state.
% values = GET_TRIAL_VALUES(S_COMP,RANDOM_INDICES_ARRAY) returns an cell
% array of strings of length reps
% 

in_method_f=get(s_comp,'Input_method_flag');
if (~(in_method_f==2) && ~(nargin==1))
    treat_error('Ilegal number of arguments for get_trial_values');
else
	switch in_method_f
		case 1
			stat_value=get(s_comp,'Static_value');
			reps_value=get(s_comp,'Static_reps');
			values= cell(reps_value,1);
            for ii=1:length(values)
                values{ii}=stat_value;
            end
        case 3
		    values=get(s_comp,'Seq_values');
	end
end