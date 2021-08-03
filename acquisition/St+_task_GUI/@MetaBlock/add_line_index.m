function  meta=add_line_index(meta,line,index)
% ADD_LINE_INDEX adds a line to the list of lines.
% line_list of this metablock in the specified index.
% META=ADD_LINE_INDEX(META,LINE,INDEX) adds the given line to the
% line_list of this metablock in the specified index.
% If index exceeds the length of the list then the envelope is added to the
% end of the list. If index is smaller then 1 or not a legitimate index
% value then an error occures.

if (~(isint(index)) || index<1)
    treat_error('Illegal INDEX input to MetaBlock/add_line_index');
end

if ~isa(line,'Basic_line')
    treat_error('Illegal Basic-Line input to MetaBlock/add_line_index');
end

list=get(meta,'Line_list');
max_loc=length(list);
if index>max_loc+1
    index=max_loc+1;
end

if index<1
    index=1;
end

if (index==max_loc+1)
   new_list={list{:},line};
elseif index==1
    new_list={line,list{:}};
else
start=list(1:index-1);
rest=list(index:end);
new_list={start{:},line rest{:}};
end

meta=set(meta,'Line_list',new_list);
