function pa5= set(pa5,varargin)
% SET Set PA5x properties and return the updated object
% Property names are:

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid PA5 property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    
    switch prop    
	case 'Device_num'
    pa5.device_num=val;
        case 'Atten'
            pa5.atten=val;
    
    otherwise
		treat_error([prop,' is not a sig_comp property']);
    end
end