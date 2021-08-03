function comp = set(comp,varargin)
% SET Set STime_comp properties and return the updated object.
% Property names are:
% Sig_comp,Input_method, Static_value, Value_formula, Static_reps, Reps_formula,
% Seq_values, Seq_values_str, Coord_index, Index_formula, Wrap, Fixed_num_data, Sweep.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
        treat_error(['The property input is not a valid Start-time property'])
    end
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
        case 'Sig_comp'
            class_name=class(val);
            if ~(strcmp(class_name,'String_comp'))
                treat_error('The given value for Sig_comp property is not a String_comp object');
            else
                comp.String_comp = val;
            end
        case 'Static_value'
            if  (is_legal_fname(comp,val))
                comp.String_comp = set(comp.String_comp,'Static_value',val);
            else
                treat_error('The file does not exist');
            end
        case 'Seq_values'
%             treat_error('File_comp doesn''t support SEQ');
            	 if (~isa(val,'cell') || isempty(val))
				    treat_error('The given value is not a legal sequence for File component'); 
				 else
                    for k=1:length(val)
				        if ~(is_legal_fname(comp,val{k}))
                          treat_error(['The given file : ',(val{k}),'  is not legal']); 
                        end
                     end%for
                     comp.String_comp = set(comp.String_comp,'Seq_values',val); 
				 end
        case 'Sweep'
            treat_error('File_comp doesn''t support SWEEP');
        otherwise
            comp.String_comp=set(comp.String_comp,prop,val);
    end
end

