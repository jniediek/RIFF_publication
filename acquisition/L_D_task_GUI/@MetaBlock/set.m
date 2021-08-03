function meta=set(meta,varargin)
% SET Set Metablock  properties from the specified object
% and return the value. Property names are:
%  Run_mode, Line_list

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not of type char'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
        case 'Run_mode'
        result=check_meta_params(meta,'Run_mode',val);
	    if result
            meta.run_mode=val;
        end
        
        case 'Line_list'
        result=check_meta_params(meta,'Line_list',val);
	    if result
            meta.line_list=val;
            meta.num_of_lines=length(meta.line_list);
       end
       
otherwise
            treat_error('MetaBlock properties are: Run_mode, Line_list');
		end     
end