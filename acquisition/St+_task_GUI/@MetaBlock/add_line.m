function  meta=add_line(meta,line)
% ADD_LINE adds the given line to the line-list of the MetaBlock.
% META=ADD_LINE(META,LINE) adds the given line to the
% line-list of this metablock.

list=get(meta,'Line_list');
loc=length(list);
meta=add_line_index(meta,line,loc+1);
