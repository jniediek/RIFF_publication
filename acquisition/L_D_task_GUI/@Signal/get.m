function val = get(sig,prop_name)
% GET Get Signal property from the specified object
% and return the value. Property names are:
% Name, Num_of_comps.

if isa(prop_name,'char')
    
	switch prop_name
	case 'Name'
        val = sig.name;
     case 'Num_of_comps'    
        val=0;
    
	otherwise
        treat_error([prop_name,' is not a valid Signal property']);
	end
    
else
    treat_error('The property input must be of type char');
end
