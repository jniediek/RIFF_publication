function  meta=remove_line_index(meta,index)
% REMOVE_LINE_INDEX removes a line from the list of lines of the MetaBlock.
% META=REMOVE_LINE_INDEX(META,INDEX) removes the line in the specified
% index from the line-list of this metablock.
% If index exceeds the length of the list then the line is removed from the
% end of the list. If index is smaller then 1 or not a legitimate index
% value then an error occures.

if (~(isint(index)) || index<1)
    treat_error('Illegal INDEX input to MetaBlock/remove_line_index');
end

list=get(meta,'Line_list');
len=length(list);

if len==0
    return;
end

if index>len
    index=len;
end

if index==1
    if len==1
        new_list={};
    else
        new_list=list(index+1:end);
    end
else
    if index==len
        n=index-1;
        new_list=list(1:n);
    else  %index~=1 && index~=len
		start=list(1:index-1);
		rest=list(index+1:end);
		new_list={start{:},rest{:}};
	end
end
meta=set(meta,'Line_list',new_list);
