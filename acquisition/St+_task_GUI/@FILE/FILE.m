function  new_sig=FILE(varargin)
%   FILE class constructor.

switch nargin
case 0
	% if no input arguments, create a default object
    m_sig=Main_signal('FILE');
    new_sig.num_of_comps=5;%assuming NEW_SIGNAL have 1 more unique component beside the basic 4.
    new_sig=class(new_sig,'FILE',m_sig);
    % assuming that the unique componentis File_comp
    fc=File_comp;
    new_sig=add_to_comp_list(new_sig,'File_Comp',fc);
case 1
	if (isa(varargin{1},'FILE'))
	    new_sig = varargin{1}; 
    end
otherwise
    treat_error('Wrong input argument to FILE constructor');
end 