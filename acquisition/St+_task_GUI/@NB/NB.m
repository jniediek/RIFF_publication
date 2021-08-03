function  nb=NB(varargin)
%   NB class constructor.

switch nargin
    case 0
        % if no input arguments, create a default object
        m_sig=Main_signal('NB');
        nb.num_of_comps=7;%assuming NB have 1 more unique component beside the basic 4.
        nb=class(nb,'NB',m_sig);
        fc=Freq_comp;
        fc=set(fc,'Input_method_line','CenFreq:');
        fc=set(fc,'constant_line','freq/reps:');
        bw=Freq_comp;
        bw=set(fc,'Input_method_line','BWHz:');
        bw=set(bw,'constant_line','BW/reps:');
        nb=add_to_comp_list(nb,'Freq_comp',fc);
        nb=add_to_comp_list(nb,'Freq_comp',bw);
    case 1
        if (isa(varargin{1},'NB'))
            nb = varargin{1};
        end
    otherwise
        treat_error('Wrong input argument to NB constructor');
end