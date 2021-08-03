function s_comp= update_input_method(s_comp,input_method,varargin)
% UPDATE_INPUT_METHOD changes the input method of this signal component.
% There are 3 input methods possible: 'STATIC_VALUE', 'SWEEP', 'SEQ_VALUES'.
% if input_method is none of the above an error occurs.
% S_COMP=UPDATE_INPUT_METHOD(S_COMP,'STATIC_VALUE',VALUE) sets the static value to
% be the given VALUE.
% S_COMP=UPDATE_INPUT_METHOD(S_COMP,'SWEEP',SDATA,EDATA,NUM_DATA,REPS,MODE,STEP)
% sets the sweep data member according to the given parameters.
% S_COMP=UPDATE_INPUT_METHOD(S_COMP,'SEQ_VALUES',VALUES) sets the sequenced values
% to the given array of values.
    
switch input_method
	case 'STATIC_VALUE'
	    if ((nargin==4) && (length(varargin)==2))
	        s_comp=set(s_comp,'Input_method','STATIC_VALUE','Static_value',varargin{1},...
	        'Fixed_num_data',varargin{2},'Static_reps',varargin{2});
	    else
	        treat_error('Wrong number of arguments for Sig_comp/update_input_method');
	    end
        
	case 'SWEEP'
        if nargin==3 && length(varargin)==1
            swp=varargin{1};
             n=get(swp,'Seq_length');
             s_comp=set(s_comp,'Input_method','SWEEP','Sweep',swp,'Fixed_num_data',n); 
       elseif nargin==8 && length(varargin)==6
	        swp=Sweep(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});
	        n=get(swp,'Seq_length');
        	s_comp=set(s_comp,'Input_method','SWEEP','Sweep',swp,'Fixed_num_data',n);
	    else
        	treat_error('Wrong number of arguments for Sig_comp/update_input_method');
    	end
        
	case 'SEQ_VALUES'
	    if nargin==3 && length(varargin{:})>=1 
        	n=length(varargin{:});
        	s_comp=set(s_comp,'Input_method','SEQ_VALUES','Seq_values',varargin{:},'Fixed_num_data',n);
	    else
        	treat_error('Wrong number of arguments for Sig_comp/update_input_method');
	    end
        
	otherwise
	    treat_error('Input method must be one of the following:  STATIC_VALUE, SWEEP, SEQ_VALUES');   
end
