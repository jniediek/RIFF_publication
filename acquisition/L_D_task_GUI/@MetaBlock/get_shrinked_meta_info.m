function meta_info_list=get_shrinked_meta_info(meta)
% GET_SHRINKED_META_INFO returns abbreviated information on the MetaBlock.
% META_INFO_LIST=GET_SHRINKED_META_INFO(META) returns abbreviated
% information on the MetaBlock.
% Each row represents a different line of the MetaBlock  where each row hold the list of
% signals defined for that line in each of the fourt channels.
num_lines=get(meta,'Num_of_lines');
str_list='';
if ~(num_lines==0)
  line_list=get(meta,'Line_list');
for q=1:num_lines
    line=line_list{q};
        for k=1:4
            chan_str=['Chan_signals_' num2str(k)];
            sig_coord=get(line,chan_str);
            str=['chan' num2str(k)];
             word_length=7;
			name_str=blanks(8);
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
        end
     str=[' ',num2str(q),chan1,chan2,chan3,chan4];
%     str=[' ',num2str(q),' ',chan1,' ',chan2,' ',chan3,' ',chan4];
    info_line=sprintf(str);
    str_list=strvcat(str_list,info_line);
end
end
meta_info_list=str_list;