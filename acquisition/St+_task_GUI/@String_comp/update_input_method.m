function s_comp= update_input_method(s_comp,input_method,varargin)
% UPDATE_INPUT_METHOD changes the input method of this signal component.
% There are one input method possible: 'STRING'.
% (future one: STRING_LIST)
% 
    
switch input_method
	case 'STRING'
	    if ((nargin==4) && (length(varargin)==2))
	        s_comp=set(s_comp,'Input_method','STRING','Static_value',varargin{1},...
	        'Fixed_num_data',varargin{2},'Static_reps',varargin{2});
	    else
	        treat_error('Wrong number of arguments for String_comp/update_input_method');
	    end
        
	otherwise
	    treat_error('Input method must be one of the following:  STRING');   
end
