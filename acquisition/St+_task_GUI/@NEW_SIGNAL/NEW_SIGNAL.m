function  new_sig=NEW_SIGNAL(varargin)
%   NEW_SIGNAL class constructor.

switch nargin
case 0
	% if no input arguments, create a default object
    m_sig=Main_signal('NEW_SIGNAL');
    new_sig.num_of_comps=5;%assuming NEW_SIGNAL have 1 more unique component beside the basic 4.
    new_sig=class(new_sig,'NEW_SIGNAL',m_sig);
    % assuming that the unique componentis Phase_comp
    new_sig=add_to_comp_list(new_sig,'Phase_comp',Phase_comp);
case 1
	if (isa(varargin{1},'NEW_SIGNAL'))
	    new_sig = varargin{1}; 
    end
otherwise
    treat_error('Wrong input argument to NEW_SIGNAL constructor');
end 