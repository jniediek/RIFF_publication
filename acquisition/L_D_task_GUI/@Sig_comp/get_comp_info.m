function info_line = get_comp_info(s_comp)
% GET_COMP_INFO extract information about the given Sig_comp object.
%  info_line = GET_COMP_INFO(s_comp) returns a character array that hold
%  information on the given Sig_comp object.
%  The content of the information depends on the Input method of the
%  component (either STATIC_VALUE, SWEEP or SEQ_VALUES).

comp_name=get(s_comp,'Name');
line_str=[comp_name,' : '];
in_method_indx=get(s_comp,'Input_method_flag');

switch in_method_indx
	case 1 %STATIC_VALUE
		const=get(s_comp,'Value_formula');
		reps=get(s_comp,'Reps_formula');
		line_str=[line_str,'CONST:[',const,';',reps,';]'];
        
	case 2 %SWEEP
		sdata=get_sweep_param(s_comp,'Sdata_formula');
		edata=get_sweep_param(s_comp,'Edata_formula');
		num=get_sweep_param(s_comp,'Num_data_formula');
		reps=get_sweep_param(s_comp,'Reps_formula');
		mode=get_sweep_param(s_comp,'Mode');
		step=get_sweep_param(s_comp,'Step');
		line_str=[line_str,'SWP:[',sdata,';',edata,';',num,';',...
		reps,';',mode,';',step,';]'];

	case 3 %SEQ_VALUES
		seq=get(s_comp,'Seq_values_str');
        seq_str='';
        if (~(isempty(seq)))
            seq_str=['[',seq{1}];
            len=10;
            if length(seq)<10
                len=length(seq);
            end
            for k=2:len
                seq_str=strcat(seq_str,',',seq{k});
            end
            if length(seq)>10
            seq_str=strcat(seq_str,',...]');
        else
            seq_str=strcat(seq_str,']');
        end
       end
		line_str=[line_str,'SEQ:',seq_str];
end

wrap=get(s_comp,'Wrap');
if wrap==1
    line_str=[line_str,' | wrap'];  
end
info_line=line_str;