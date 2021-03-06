function info_line = get_comp_info(s_comp)
% GET_COMP_INFO extract information about the given String_comp object.
%  info_line = GET_COMP_INFO(s_comp) returns a character array that hold
%  information on the given String_comp object.
%  The content of the information depends on the Input method of the
%  component (right now only SFILE).

comp_name=get(s_comp,'Name');
line_str=[comp_name,' : '];
in_method_indx=get(s_comp,'Input_method_flag');

switch in_method_indx
	case 1 %String
		const=get(s_comp,'Static_value');
		reps=get(s_comp,'Reps_formula');
		line_str=[line_str,'CONST:[',const,';',reps,';]'];
end
wrap=get(s_comp,'Wrap');
if wrap==1
    line_str=[line_str,' | wrap'];  
end
info_line=line_str;