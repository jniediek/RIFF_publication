function  new_sig=PULSE(varargin)
%   NEW_SIGNAL class constructor.

switch nargin
case 0
	% if no input arguments, create a default object
    m_sig=Main_signal('PULSE');
    new_sig.num_of_comps=4;%PULSE has the basic 4 components.
    new_sig=class(new_sig,'PULSE',m_sig);
case 1
	if (isa(varargin{1},'PULSE'))
	    new_sig = varargin{1}; 
    end
otherwise
    treat_error('Wrong input argument to PULSE constructor');
end 