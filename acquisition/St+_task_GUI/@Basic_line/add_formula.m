function line=add_formula(line,comp_tag)
% ADD_FORMULA adds a tag-name to the list of graphical tags
% that contain a formula as an input.
% Line=ADD_FORMULA(LINE,COMP_TAG) adds the given tag-name to 
% the end of the LINE's list of graphical tags that contain a formula as
% their input.

if (~isa(comp_tag,'char') || isempty(comp_tag))
	treat_error('The input is empty or is not of type char');
end

list=get(line,'Formula_list');
index=length(list);
match= strmatch(comp_tag,list,'exact');
if ~isempty(match)%already exist in list
    return;
end
index=index+1;
if (index==1)
   new_list={comp_tag};
else
    new_list={list{:},comp_tag};
end
line=set(line,'Formula_list',new_list);
