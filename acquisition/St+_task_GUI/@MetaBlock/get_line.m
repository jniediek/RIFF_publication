function line=get_line(meta,index)
% GET_LINE returns a Basic-line from the list of lines of the MetaBlock.
% META=GET_LINE(META,INDEX) returns the line in the specified index
% in this metablock's line list.

if (~(isint(index)) || index<1)
    treat_error('Illegal INDEX input to MetaBlock/get_line');
end

list=get(meta,'Line_list');
loc=length(list);
if index>loc
    treat_error('Illegal line INDEX - index exceeds number of lines of the MetaBlock');
end
line=list{index};
