function  line=remove_formula(line,comp_tag)
% REMOVE_FORMULA removes a tag-name from the tag-name list of graphical
% objects that contain formula as an input.
% LINE=REMOVE_FORMULA(LINE,COMP_TAG) removes the given tag_name from the
% tag-name list of the given line which is a list of graphical objects that 
% contain formula as an input.

if (~isa(comp_tag,'char') || isempty(comp_tag))
	treat_error('The input is empty or is not of type char');
end

list=get(line,'Formula_list');
len=length(list);

if len==0
    return;
end

% checks if the given tag-name exists in the list
index= strmatch(comp_tag,list,'exact');
if isempty(index)
    return;
end

if index==1
	if len==1
	    new_list={};
	else
	    new_list=list(index+1:end);
    end
elseif index==len
       new_list=list(1:index-1);
else  
	start=list(1:index-1);
	rest=list(index+1:end);
	new_list={start{:},rest{:}};
end

line=set(line,'Formula_list',new_list);
