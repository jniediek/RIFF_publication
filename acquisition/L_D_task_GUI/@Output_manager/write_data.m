function write_data(out)
fid=get(out,'Fid');
d=datestr(now);
date_line=['% ',d];
fprintf(fid,'%s',date_line);
fprintf(fid,'\n');

meta_data_title=['%% MetaBlock data : %%%%%%%%%%%%%%%%%%%%%%%'];
fprintf(fid,'%s',meta_data_title);
fprintf(fid,'\n');
meta_data_title2=['%% METADATA FILE VERSION = 2.0 %%%%%%%%%%%%%%%%%%%%%%'];
fprintf(fid,'%s',meta_data_title2);
fprintf(fid,'\n');
meta=get(out,'StimList');
metablock_data=get_file_format(meta);
for k=1:length(metablock_data)
    fprintf(fid,'%s',metablock_data{k});
    fprintf(fid,'\n');
end



