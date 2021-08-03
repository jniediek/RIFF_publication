function res=check_params(varargin)
% res=CHECK_PARAMS(PARAM1,VAL1...) checks the validity for a Basic_line object.
% Checks that PARAM1 field can hold the given VAL1 value and the same for 
% PARAM2,VAL2 and so on.
% If all params are legal - returns 1. Otherwise returns 0.
 
global LINE_REAR_NAMES;
global LINE_LEAR_NAMES;
global LINE_SAMP_RATE_LIST;

res=1;
property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not of type char']);
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
switch prop
	case 'Right_ear'
		if ~(isa(val,'char'))
            res=0;
			treat_error('Right_ear must be a of type char');
		end
	    match=strmatch(val,LINE_REAR_NAMES,'exact');
		if isempty(match)
            res=0;
			treat_error('Right_ear must be one of the following chars: 1,2,3,4,3+4,2+3+4,1+2+3+4,SILENCE');
		end
        
	case 'Left_ear'
        if ~(isa(val,'char'))
            res=0;
			treat_error('Left_ear must be a of type char');
        end
        match=strmatch(val,LINE_LEAR_NAMES,'exact');
		if isempty(match)
            res=0;
		    treat_error('Left_ear must be one of the following chars: 1,2,3,4,1+2,1+2+4,1+2+3+4,SILENCE');
		end
        
	case 'Samp_rate'
        if (~isa(val,'double') || ~(length(val)==1))
            res=0;
			treat_error('Period must be a scalar');
        end
        match=find(val==LINE_SAMP_RATE_LIST);
		if isempty(match)
            res=0;
		    treat_error('Samp_rate must be one of the following doubles: 32000, 44100, 48000, 64000, 88200, 96000, 128000,192000');
        end
    
	case 'Chan_signals'
        s=size(val);
        if (~isa(val,'cell') || ~all(s==[1,4]))
            res=0;
			treat_error('Chan_signals must be a cell array of size (1 x 4)');
        end
		for k=1:4
			if ((~isempty(val{k}) && ~isa(val{k},'sig_coordinator'))  || isa(val{k},'double'))
                res=0;
                treat_error('Chan_signals must be a cell array of Signal-coordinators');
                break;
			end
		end%for
        
    case 'Trial_dur_comp'
        if (~isa(val,'Trial_dur_comp'))
            res=0;
			treat_error('The input is not a Trial_dur_comp object');
        end
        
    case 'Err' 
        if (~isa(val,'char'))
            res=0;
			treat_error('The input is not of type char');
        end
        
    case 'Formula_list'
        if ~iscellstr(val) 
            res=0;
			treat_error('The input is not a cell array of strings');
        end
        s=size(val);
        if ~(size(1)==1)
            res=0;
            treat_error('The input must be a cell array with one row only');
        end       
        
    otherwise
        res=0;
		treat_error('Line properties are: Right_ear, Left_ear, Period,  Chan_signals',...
		'Trial_dur_comp,Err, Formula_list');
    end%switch
end%while

