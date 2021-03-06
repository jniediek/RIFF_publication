function [valid_flag,err,is_formula]=check_if_legal(comp,prop,val,def_arr,var_arr)
%  CHECK_IF_LEGAL checks the legacy of the given val as a Level_comp-object property.
%   [VALID_FLAG,ERR,IS_FORMULA]=CHECK_IF_LEGAL(COMP,PROP,VAL,DEF_ARR,
%   VAR_ARR) checks that VAL is a legal value for the Level_comp-object property-PROP.
%   VAL will be legal in the following cases:
%   1. It is a numeric value that falls into the  range of legal values for the specified property.
%   2. It is a formula with varaibles from VAR_ARR or from the DEFAULTS varaibles and that
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
%   Static_value, Static_reps, Coord_index, Num_data, Reps.

 valid_flag=1; 
 err='';
 is_formula=0;
 
 if ~(isa(val,'char'))
    valid_flag=0; 
    err='The checked value must be given as string';
    return;
end

 numeric=str2num(val);
 
 if ((~isempty(numeric)) && ~(isscalar(numeric)))
    valid_flag=0; 
     err='The checked value must be a string representation of a scalar';
      return;
 end

MAX_LEVEL=get(comp,'MAX_LEVEL');
  switch prop
	case 'Static_value'
		if (~isempty(numeric))%dealing with a constant number
			if (~( is_legal_level(comp,numeric)))
			    valid_flag=0; 
                
			    err=['Level must be non negative and maximum ',num2str(MAX_LEVEL)];
			end
		else%dealing with a potential formula
		
		[is_formula,final_value,def_exist]=is_legal_formula(val,def_arr,var_arr);
		if (is_formula)
			if (final_value<0) 
			    valid_flag=0; 
			    err=['Level must be non negative and maximum ',num2str(MAX_LEVEL)];
                
                
			end
		end
			if ~(is_formula)
			    valid_flag=0; 
			    err='Not a legal expression'; 
			end
		end
        
	otherwise
	    [valid_flag,err,is_formula]=check_if_legal(comp.Sig_comp,prop,val,def_arr,var_arr);
end
    
    