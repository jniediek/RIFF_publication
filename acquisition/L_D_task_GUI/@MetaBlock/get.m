function val=get(meta,prop_name)
% GET Get Metablock property from the specified object
% and return the value. Property names are:
%  Run_mode,Line_list,Num_of_lines,Num_of_trials

if isa(prop_name,'char')
	switch prop_name
		case 'Run_mode'
		    val=meta.run_mode;
		case 'Line_list'
		    val=meta.line_list;
		case 'Num_of_lines'
		    val=meta.num_of_lines;
		case   'Num_of_trials'
		    trials=0;
		    num_lines=meta.num_of_lines;
		    for k=1:num_lines
                line=get_line(meta,k);
                trials=trials+get(line,'Line_num_of_trials');
		    end
		    val=trials;
        case   'Maximum_trials_among_lines'
		    num_lines=meta.num_of_lines;
            line_trials=zeros(1,num_lines);
		    for k=1:num_lines
                line=get_line(meta,k);
                line_trials(k)=get(line,'Line_num_of_trials');
		    end
            val=max(line_trials);

	otherwise
         treat_error('MetaBlock properties are:  Run_mode, Line_list, Num_of_lines, Num_of_trials ');
	end
    
    else
    treat_error('The property input must be of type char');
end
