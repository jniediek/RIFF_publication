function   [sig_comp,err_msg,changed]=update_final_seq_values(component,def_arr,var_arr)
%  UPDATE_FINAL_SEQ_VALUES calculates the expressions in the sequence according to
%  the values of the varaibles that appear in the expressions. 
%  [SIG_COMP,ERR_MSG,CHANGED]=UPDATE_FINAL_SEQ_VALUES(COMPONENT,DEF_ARR,VAR_ARR)
%  calculates the expressions in the sequence values of the given component
%  by replacing varaibles with their values. If the final value is not
%  changed since the last calculation, then CHANGED=0.If the final value
%  that was calculated is not legal, then ERROR will hold the relevant error
%  message. If the value is legal then the Sequenced values of this
%  component is updated and the new component is returned.
%  The expressions can contains 2 types of varaibles: dynamic type (varaibles
%  that are defined in DEF_ARR) or non-dynamic (varaibles that are defined
%  in VAR_ARR).
%  For example: suppose that this signal component holds a sequence of the 
%  following  values : { 2000,A,6000,BF*2,9000+B,NBThr } and that at the time of
%  calculation : A=500; B=400; BF=1000; NBThr=100. Then UPDATE_FINAL_SEQ_VALUES 
%  will update their values as  : { 2000,500,6000,2000,9400,100 } .
%  If, on the other hand, this signal component holds a sequence of the 
%  following  values : { 2000,C,6000, BF-2000 } and that at the time of
%  calculation : C is not defined in var_arr and  BF=1000; . Then ERR_MSG 
%  will hold an error report since C is not a legal expression and the
%  component will not be updated.

seq_val_str=get(component,'Seq_values_str'); %holds the expressions
seq_val=get(component,'Seq_values');%holds the expression's values
s1=size(def_arr);
s2=size(var_arr);
was_changed=0;
change_flag=0;
err='';
err_msg='';

for k=1:length(seq_val_str)
		was_changed=0;
		val=seq_val_str{k} ;%the expression that it's value is being calculated
		new_str=val;
		for q=1:s1(2) %replacing varaibles from def_arr with their corresponding values
			rep=num2str(def_arr{2,q});
			new_str=strrep(new_str,def_arr{1,q},rep);
		end%for
		if (strcmp(new_str,val)==0)%varaible from def_arr exists in val
		    was_changed=1;
		end%if
		before_str=new_str;
		if (~isempty(var_arr))
			for q=1:s2(2)%replacing varaibles from var_arr with their corresponding values
			    rep=num2str(var_arr{2,q});
			    new_str=strrep(new_str,var_arr{1,q},rep);
			end%for
		end%if
		if (strcmp(new_str,before_str)==0)%varaible from var_arr exists in val
		    was_changed=1;
		end
        
        tf = isletter(new_str);
        if any(tf)
            err=['An undefined varaible exists in ',new_str];
            break;
        end
        
		if (was_changed) % if the current expression contains varaibles and should be recalculated
			[valid_flag,er,is_formula]=check_if_legal(component,'Static_value',new_str,def_arr,var_arr);
			if (~valid_flag)
			    err=['An illegal value was found: ',new_str,' .',er];
			    break;
            else
                eval(['num=',new_str,';']);
			    seq_val(k)=num;
                change_flag=1;
			end
           end
end%for

if(isempty(err) && change_flag)
    sig_comp=set(component,'Seq_values',seq_val);
    changed=1;
else
    sig_comp=component;
    changed=0;
end
err_msg=err;