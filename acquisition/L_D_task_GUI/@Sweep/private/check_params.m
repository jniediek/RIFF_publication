function res=check_params(varargin)
% res=CHECK_PARAMS(PARAM1,VAL1...) checks the validity for a Sweep object.
% Checks that PARAM1 field can hold the given VAL1 value and the same for 
% PARAM2,VAL2 and so on.
% If all params are legal - returns 1. Otherwise returns 0.
 
global SWEEP_MAX_TRIALS;
global SWEEP_MODE_NAMES,
global SWEEP_STEP_NAMES;

SWEEP_MODE_NAMES = {'SEQ','RND'};
SWEEP_STEP_NAMES = {'LIN','LOG','1/LIN','1/LOG'};
SWEEP_MAX_TRIALS = 1000;

res=1;
property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    val = property_argin{2};
    property_argin = property_argin(3:end);
switch prop
	case 'Sdata' 
		if (~(length(val)==1) || ~(isnumeric(val)))
        res=0;
		error('Start data must be a scalar');
		elseif (val==0 && ~strcmp(varargin{12},'LIN'))
        res=0;
		error('Start data may be zero only while step=LIN\ncurrent step = %s',varargin{12});
		end
        
	case 'Edata' 
		if (~(length(val)==1) || ~(isnumeric(val)))
        res=0;
		error('End data must be a scalar');
		elseif (val==0 && ~strcmp(varargin{12},'LIN'))
		res=0;
		error('End data may be zero only while step=LIN\ncurrent step = %s',varargin{12});
		end
        
	case 'Num_data'
		if (~isint(val) || val<1)
        res=0;
		error('Number of data must be positive integer');
		end
        reps=varargin{8};
        if (~isint(reps) || reps<1)
        res=0;
		error('Reps must be positive integer');
		end
		if (reps*val)>SWEEP_MAX_TRIALS
        res=0;
		error('Number of trials is out of range\nnumber of trials = %d',reps*val);
		end
    
	case 'Reps'
		if (~isint(val) || val<1)
        res=0;
		error('Reps must be positive integer');
		end
        num=varargin{6};
        if (~isint(num) || num<1)
        res=0;
		error('Number of data must be positive integer');
		end
		if (val*varargin{6})>SWEEP_MAX_TRIALS
        res=0;
		error('Number of trials is out of range\nnumber of trials = %d',val*num);
		end
        
	case 'Mode'
        if (~isa(val,'char'))
            res=0;
            error('Bad mode');
		end
		mode_match = strmatch(val,SWEEP_MODE_NAMES,'exact'); 
		if isempty(mode_match)
            res=0;
	    	error('Bad mode\nmode = %s',val);
		end
        
	case 'Step'
        if (~isa(val,'char'))
            res=0;
            error('Bad step');
		end
		step_match = strmatch(val,SWEEP_STEP_NAMES,'exact'); 
		if isempty(step_match)
            res=0;
		    error('Bad step\nstep = %s',val);
       elseif (~(step_match==1) && (varargin{2}==0 || varargin{4}==0))
            error('Start and End data may be zero only while step=LIN');
      end
	otherwise
        res=0;
		error([param,' is not a valid Sweep property. Properties are : Sdata,Edata, Num_data, Reps, Mode, Step.']);
    end
end