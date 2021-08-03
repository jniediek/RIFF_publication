function meta_info=get_meta_info(meta)
% GET_META_INFO returns information on the MetabBlock object.
% META_INFO=GET_META_INFO(META) returns information on the MetabBlock object.
% Each row represents a different line of the MetaBlock  where each row hold the list of
% signals defined for that line in each of the fourt channels.
num_lines=get(meta,'Num_of_lines');
str_list='';
if ~(num_lines==0)
	line_list=get(meta,'Line_list'); 
	for q=1:num_lines
		line=line_list{q};
		signals=get(line,'Chan_signals');
		for k=1:4
			chan_str=num2str(k);
			sig_coord=signals{k};
			str=['chan' chan_str];
            word_length=7;
			name_str=blanks(12);
			if ~isempty(sig_coord)
                name=get(sig_coord,'Name');
                if length(name)>word_length
                    len=word_length;
                else
                    len=length(name);
                end
			    name_str(1:len)=name(1:len);
			end
			eval([str '=name_str;']);
		end% for k=1:4
		str2=['     ',num2str(q),'\t',chan1,'\t',chan2,'\t',chan3,'\t',chan4];
        info_line=sprintf(str2);
        str_list=strvcat(str_list,info_line);
    end%for q=1:num_lines
end%if
meta_info=str_list;