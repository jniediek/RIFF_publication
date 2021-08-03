function s_coord = Sig_coordinator(varargin)
%   SIG_COORDINATOR class constructor.
%   S_COORD = SIG_COORDINATOR(MAIN_SIGNAL) constructs a Signal Coordinator
%   for the given Main_signal. 

switch nargin
case 0
	s_coord.m_sig=Main_signal;
	coord=Coordinator(s_coord.m_sig);
	s_coord=class(s_coord,'Sig_coordinator',coord);

case 1  
	if (isa(varargin{1},'Sig_coordinator'))
	    s_coord = varargin{1}; 
	else
		if (isa(varargin{1},'Main_signal'))
		    s_coord.m_sig=varargin{1};
		    coord=Coordinator(varargin{1});    
		    s_coord=class(s_coord,'Sig_coordinator',coord);
		else
		    treat_error('Wrong input for Sig_coordinator. Usage: Sig_coordinator(<Main_signal>)');
		end
	end
    
case 2
    if (isa(varargin{1},'Main_signal') && isa(varargin{2},'Trial_dur_comp'))
		    s_coord.m_sig=varargin{1};
            coord=Coordinator(varargin{1},varargin{2});    
            s_coord=class(s_coord,'Sig_coordinator',coord);
    else
        treat_error('Wrong input for Sig_coordinator. Usage: Sig_coordinator(<Main_signal>,<Trial_dur_comp>)');    
    end
    
otherwise
    treat_error('Wrong number of input arguments for Sig_coordinator. Usage: Sig_coordinator(m_sig)');
end
       
      