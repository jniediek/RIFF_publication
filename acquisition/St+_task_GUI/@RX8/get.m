function val= get(rx8,prop)
% GET Get RX8  property from the specified object
% and return the value. Property names are:

if isa(prop,'char')
	switch prop
    case 'Device_num'
        val=rx8.device_num;
    case 'Controler'
        val=rx8.controler;    
    otherwise
        treat_error('The property input must be of type char');
    end
end