function res=check_meta_params(meta,varargin)
% res=CHECK_PARAMS(PARAM1,VAL1...) checks the validity for a MetaBlock object.
% Checks that PARAM1 field can hold the given VAL1 value and the same for 
% PARAM2,VAL2 and so on.
% If all params are legal - returns 1. Otherwise returns 0.

global META_RUN_MODE_NAMES;
res=1;
property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not of type char'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    
switch prop
	case 'Run_mode'
		if ~(isa(val,'char'))
            res=0;
			treat_error('Run_mode must be a of type char');
        end
	    match=strmatch(val,META_RUN_MODE_NAMES,'exact');
		if isempty(match)
            res=0;
			treat_error('Run_mode must be one of the following chars: SEQ, PART_RND');
		end 
        
    case 'Line_list'
       if (~isa(val,'cell'))
           res=0;
			treat_error('Line_list must be a cell array of Lines');
        end
        if ~isempty(val)
			for k=1:length(val)
				if (~isa(val{k},'Basic_line'))
                    res=0;
                    treat_error('Line_list must be a cell array of Basic-lines');
                    break;
				end
			end%for
        end
        
    otherwise
		treat_error('MetaBlock properties are: Run_mode, Line_list');
    end%switch
end%while