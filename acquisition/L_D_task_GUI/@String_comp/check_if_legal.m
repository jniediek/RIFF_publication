function [valid_flag,err,is_formula]=check_if_legal(comp,prop,val,def_arr,var_arr)
%  CHECK_IF_LEGAL checks the legacy of the given String_comp property.
%   [VALID_FLAG,ERR,IS_FORMULA]=CHECK_IF_LEGAL(COMP,PROP,VAL,DEF_ARR,
%   VAR_ARR) checks that VAL is a legal value for the Sig_comp property-PROP.
%   VAL will be legal in the following cases:
%   1. It is a numeric value that falls into the  range of legal values for the specified property.
%   2. It is a formula with varaibles from VAR_ARR  or from the DEF_ARR and that
%   it's calculated value falls into the  range of legal values for the specified property.
%   VAR_ARR is a {2xn} cell array that holds in each collumn  varaible name
%   and value. This array represents a non-dynamic varaibles "pool" .
%   DEF_ARR is a {2x3} cell array of the form:
%   {'BFThr','NBThr''BF' ; (BFThr_value),(NBThr_value),(BF_value)}.
%  This array represents a dynamic varaibles "pool" (the values of the varaibles can
%   change during run-time) .
%   CHECK_IF_LEGAL returns VALID_FLAG=1, ERR=''  if VAL is legal, and IS_FORMULA=1 or 0
%   depending if VAL is a formula or not.
%   CHECK_IF_LEGAL returns VALID_FLAG=0, ERR=(relevent error message)  if VAL is illlegal, 
%   and IS_FORMULA=1or 0 depending if VAL is a formula or not.
%   PROP can be one of the following :
%   Static_reps, Coord_index, Num_data, Reps.

valid_flag=1; 
err='';
is_formula=0;
if strcmp(prop,'Static_value')
    if ~ischar(val)
        valid_flag=0;
        err=['string is needed for ',prop];
        return
    end
end

if ~(isa(val,'char'))
    valid_flag=0; 
    err='The checked value must be given as string';
    return;
end

numeric=str2num(val);

if ((~isempty(numeric)) && ~(length(numeric)==1))
    valid_flag=0; 
     err='The checked value must be a string representation of a scalar';
      return;
end

switch prop
        
	case {'Static_reps','Reps'}
		if (~isempty(numeric)) %dealing with a numberic value
			if (numeric<1  || ~isint(numeric))
				valid_flag=0; 
				err=[prop,' must be a positive integer'];
			end
            if (strcmp(prop,'Reps')) 
            num_data=get_sweep_param(comp,'Num_data');
             max_trials=get(get(comp,'Sweep'),'SWEEP_MAX_TRIALS');
            if (num_data*numeric>max_trials)
                valid_flag=0; 
				err=['Number of trials is out of range. Number of trials = ',num2str(num_data*numeric)];
			 end   
         end
             if (strcmp(prop,'Static_reps')) 
                 max_trials=get(comp,'SIGNAL_MAX_TRIALS');
                if (numeric>max_trials)
                    valid_flag=0; 
					err=['Number of trials is out of range. Number of trials = ',num2str(numeric)];
				 end   
       end
        else %dealing with a potential formula
			[is_formula,final_value,def_exist]=is_legal_formula(val,def_arr,var_arr);
			if (is_formula)
				if (~isempty(final_value) && (final_value<1  || ~isint(final_value)))
					valid_flag=0; 
					err=[prop,' must be a positive integer'];
				end
            elseif ~(is_formula)
				valid_flag=0; 
				err=['Not a legal expression for ',prop];
			end
		end
        
	case {'Coord_index','Num_data'}
       if (strcmp(prop,'Coord_index') && isa(val,'char') && isempty(val))
		    return;
		end
	if (~isempty(numeric)) %dealing with a constant number
        if (strcmp(prop,'Num_data') && numeric==0)
            valid_flag=0; 
			err=['Num data must be a positive integer']; 
		    return;
		end
		if (numeric<0  || ~isint(numeric))
			valid_flag=0; 
			err=[prop,' must be a non-negative integer'];
		end
        if (strcmp(prop,'Num_data')) 
            reps=get_sweep_param(comp,'Reps');
            max_trials=get(get(comp,'Sweep'),'SWEEP_MAX_TRIALS');
            if (reps*numeric>max_trials)
                valid_flag=0; 
				err=['Number of trials is out of range. Number of trials  ',num2str(reps*numeric)];
			end   
      end
	else
		[is_formula,final_value,def_exist]=is_legal_formula(val,def_arr,var_arr);
		if (is_formula)
            if strcmp(prop,'Coord_index')
                if (~isempty(final_value) && (~isint(final_value) || final_value<0)) %dealing with a numberic value
                    valid_flag=0; 
                    err=[prop,' must be a non-negative integer'];
                end
            elseif strcmp(prop,'Num_data')
                if (~isempty(final_value) && (final_value<=0  || ~isint(final_value))) %dealing with a numberic value
                    valid_flag=0; 
                    err=[prop,' must be a non-negative integer'];
                end
            end
        elseif ~(is_formula)
			valid_flag=0; 
			err=['Not a legal expression for ',prop]; 
		end
	end
    
	otherwise
	valid_flag=0; 
	err=[prop ' is not a valid Sig_comp property'];
end

