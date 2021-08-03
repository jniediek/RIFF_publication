function  m_sig = Main_signal(varargin)
%   Main_signal class constructor.
%   Main_signal(name) constructs a signal with a given name.
%   Main_signal is the base class of all signals that are not envelopes.
%   Every main signal has a Level component, start time, end time and ramp
%   length components that define the ramp parameters. The state of each of the above can be
%   one of the following:
%   1. static - not swept and not using sequenced values.
%   2. swept values.
%   3. using sequenced values.

switch nargin
case 0
		% if no input arguments, create a default object
		name='none';
		m_sig.envelope_list={};
        m_sig.num_of_env=0;
        m_sig.comp_list={Level_comp,STime_comp,ETime_comp,Ramp_comp};
        m_sig.comp_list_str={'Level_comp','STime_comp' ,'ETime_comp' ,'Ramp_comp'};
		sig=Signal(name);
		m_sig=class(m_sig,'Main_signal',sig);

case 1
		if (isa(varargin{1},'Main_signal'))
		    m_sig = varargin{1}; 
		elseif (isa(varargin{1},'char'))
			name=varargin{1};
			m_sig.envelope_list={};
			m_sig.num_of_env=0;
            m_sig.comp_list={Level_comp,STime_comp,ETime_comp,Ramp_comp};
            m_sig.comp_list_str={'Level_comp','STime_comp' ,'ETime_comp' ,'Ramp_comp'};
			sig=Signal(name);
			m_sig=class(m_sig,'Main_signal',sig);
		else
		    treat_error('Input argument is not a Main_signal object and not a signal name');
        end
    
otherwise
        treat_error('Wrong input argument to Main_signal');
end
