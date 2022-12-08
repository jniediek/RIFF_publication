function val= get(pa5,prop)
% GET Get PA%X  property from the specified object
% and return the value. Property names are:

if isa(prop,'char')
	switch prop
    case 'Device_num'
        val=pa5.device_num;
    case 'Controler'
        val=pa5.controler;    
        case 'Atten'
            val=pa5.atten;
    otherwise
        treat_error('The property input must be of type char');
    end
end