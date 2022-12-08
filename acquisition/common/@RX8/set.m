function rx8= set(rx8,varargin)
% SET Set RX8 properties and return the updated object
% Property names are:

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid RX8 property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    
    switch prop    
	case 'Device_num'
%         if ~(isa(val,'char'))
%             treat_error('Input_method must be STATIC_VALUE,SWEEP or SEQ_VALUES');
%         end
    rx8.device_num=val;
    
    otherwise
		treat_error([prop,' is not a sig_comp property']);
    end
end