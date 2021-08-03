function  freq=FREQ(varargin)
%   FREQ class constructor.

switch nargin
    case 0
        % if no input arguments, create a default object
        m_sig=Main_signal('FREQ');
        freq.num_of_comps=5;
        freq=class(freq,'FREQ',m_sig);
        freq=add_to_comp_list(freq,'Freq_comp',Freq_comp);
    case 1
        if (isa(varargin{1},'FREQ'))
            freq = varargin{1};
        end
    otherwise
        treat_error('Wrong input argument to FREQ constructor');
end
