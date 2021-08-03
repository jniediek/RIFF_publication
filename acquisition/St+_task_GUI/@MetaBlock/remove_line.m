function  meta=remove_line(meta)
% REMOVE_LINE removes the last line from the list of lines of the MetaBlock.
% META=REMOVE_LINE_INDEX(META) removes the last line from the list of lines
% of the MetaBlock and returns the new MetaBlock.


list=get(meta,'Line_list');
loc=length(list);
if loc==0
    return;
end
meta=remove_line_index(meta,loc);
