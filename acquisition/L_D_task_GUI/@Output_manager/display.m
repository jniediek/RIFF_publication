function display(obj) 
disp(sprintf('%s object', class(obj)))
disp(struct(obj))
t=struct(obj);
whos('t')