function  bbn=BBN(varargin)
%   BBN class constructor.

switch nargin
	case 0
		% if no input arguments, create a default object
		m_sig=Main_signal('BBN');
        bbn.num_of_comps=length(get(m_sig,'Comp_list'));
		bbn=class(bbn,'BBN',m_sig);
        level=get(bbn,'Level_comp');
        level=set(level,'Static_value',30);
        bbn=set(bbn,'Level_comp',level);
        
	otherwise
	    treat_error('Wrong input argument to BBN constructor');
end     



   