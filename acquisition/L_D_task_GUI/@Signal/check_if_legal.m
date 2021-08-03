function [valid_flag,err,is_formula]=check_if_legal(sig,comp,prop,val,def_arr,var_arr)
%  CHECK_IF_LEGAL checks the legacy of the given Signal component property.
%   [VALID_FLAG,ERR,IS_FORMULA]=CHECK_IF_LEGAL(SIG,COMP,PROP,VAL,DEF_ARR,VAR_ARR) 
%   checks that VAL is a legal value as the Signal component-object property-PROP.
%   VAL will be legal in the following cases:
%   1. It is a numeric value that falls into the  range of legal values for the specified property.
%   2. It is a formula with varaibles from VAR_ARR  or from the DEFAULTS and that
%   it's calculated value falls into the  range of legal values for the specified property.
%   VAR_ARR is a {2xn} cell array that holds in each collumn : varaible name
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
%   Static_value,Static_reps, Coord_index, Num_data, Reps.

valid_flag=1;
err='';
is_formula=0;

num_comps=get(sig,'Num_of_comps');
if num_comps>0
    if ~(isa(comp,'Sig_comp') || isa(comp,'String_comp')) 
         treat_error(['Wrong input for component parameter']);
     end
     
	if ~(isa(val,'char'))
        valid_flag=0; 
        err='The checked value must be given as string';
        return;
    end
    %%%%%%%%%%%%% added
	if isempty(val)
        valid_flag=0; 
        err='The checked value cant be empty';
        return;
    end
    %%%%%%%%%%%%%
    if isa(comp,'String_comp')  & strcmp(prop,'Static_value')
        if  ~(is_legal_fname(comp,val))
            valid_flag=0;
            err='File does not exist or is wrong format';
        end
        return
    end
    
	numeric=str2num(val);
	
	if ((~isempty(numeric)) && ~(length(numeric)==1))
		valid_flag=0; 
		err='The checked value must be a string representation of a scalar';
		return;
	end
	
        switch prop
            case 'Num_data'
              if (~isempty(numeric))%dealing with a constant number
                      if ((~isint(numeric)) || ~(numeric>0))
                          valid_flag=0; 
                          err='Num_data must be a non negative integer';
                      end
                      reps=get_sweep_param(comp,'Reps');
                       max_trials=get(get(comp,'Sweep'),'SWEEP_MAX_TRIALS');
                       if (reps*numeric>max_trials)
                            valid_flag=0; 
						    err=['Number of trials is out of range. Number of trials  ',num2str(reps*numeric)];
				        end   
              else
                      [is_formula,final_value,def_exist]=is_legal_formula(val,def_arr,var_arr);
                      if (is_formula)
                          if (~(isempty(final_value)) && (~(final_value>0)  || ~(isint(final_value))))%dealing with a constant number
                                valid_flag=0; 
                                 err='Num_data must be a non negative integer';
                            end
                         elseif ~(is_formula)
                              valid_flag=0; 
                              err='Not a legal expression'; 
                        end
            end
            
            case 'Reps'
                if (~isempty(numeric))%dealing with a constant number
                       if (numeric<=0  || ~isint(numeric))
                              valid_flag=0; 
                              err='Reps must be a positive integer';
                         end   
                         num_data=get_sweep_param(comp,'Num_data');
                         max_trials=get(get(comp,'Sweep'),'SWEEP_MAX_TRIALS');
                         if (num_data*numeric>max_trials)
                             valid_flag=0; 
					    	 err=['Number of trials is out of range. Number of trials = ',num2str(num_data*numeric)];
					     end   
                  else
                       [is_formula,final_value,def_exist]=is_legal_formula(val,def_arr,var_arr);
                       if (is_formula)
                                if (~isempty(final_value) && (final_value<1  || ~isint(final_value)))%dealing with a constant number
                                   valid_flag=0; 
                                   err='Reps must be a positive integer';
                                 end
                        elseif ~(is_formula)
                                  valid_flag=0; 
                                    err='Not a legal expression'; 
                        end
                  end
                
           otherwise
            [valid_flag,err,is_formula]=check_if_legal(comp,prop,val,def_arr,var_arr);
        end
	end

