function comp = set(comp,varargin)
% SET Set Freq_comp properties and return the updated object
% Property names are:
% Name,Sig_comp,Swp_on,Seq_on,Static_value,Sweep,Seq_values.

property_argin = varargin;
while length(property_argin) >= 2,
	prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid Frequency property'])
    end 
	val = property_argin{2};
	property_argin = property_argin(3:end);
	switch prop
		case 'Sig_comp'
            class_name=class(val);
			if ~(strcmp(class_name,'Sig_comp'))
			    treat_error('The given value for Sig_comp property is not a Sig_comp object'); 
			else
			    comp.Sig_comp = val; 
			end
            case 'Static_value'
			if  (is_legal_freq(comp,val))
                comp.Sig_comp = set(comp.Sig_comp,'Static_value',val); 
			else
			    treat_error('The given value is not a legal Frequency'); 
			end
            case 'Seq_values'
				if (~isa(val,'double') || isempty(val))
				    treat_error('The given value is not a legal sequence for Freq component'); 
				else
                    for k=1:length(val)
				        if ~(is_legal_freq(comp,val(k)))
                          treat_error(['The given value : ',num2str(val(k)),'  is not a legal Frequency']); 
                        end
                     end%for
                     comp.Sig_comp = set(comp.Sig_comp,'Seq_values',val); 
				end
            case 'Sweep'
				if (~isa(val,'Sweep'))  
                    treat_error('The given value is not a legal Sweep object'); 
				else
                    sdata=get(val,'Sdata');
                    edata=get(val,'Edata');
                    if  (~is_legal_freq(comp,sdata) || ~is_legal_freq(comp,edata))
                        treat_error('The given value is not a legal Frequency'); 
                    else
                        comp.Sig_comp = set(comp.Sig_comp,'Sweep',val);   
                    end
				end
		otherwise
		    comp.Sig_comp=set(comp.Sig_comp,prop,val);
	end     
end

