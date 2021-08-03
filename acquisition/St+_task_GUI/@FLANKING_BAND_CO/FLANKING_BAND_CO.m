function  flank=FLANKING_BAND_CO(varargin)
%   FLANKING_BAND class constructor.

switch nargin
case 0
	% if no input arguments, create a default object
    m_sig=Main_signal('FLANKING_BAND_CO');
    flank.num_of_comps=6;% FLANKING_BAND has 2 more unique components beside the basic 4.
% load filtercoefficients
    load('@FLANKING_BAND_CO\filtercoeffs.txt');
    flank.filtercoeffs=filtercoeffs;
    flank=class(flank,'FLANKING_BAND_CO',m_sig);
    % assuming that the unique componentis Phase_comp
    fc=Freq_comp;
    fc=set(fc,'Input_method_line','LoFreq:');
    fc=set(fc,'constant_line','freq/reps:');
    bw=Freq_comp;
    bw=set(fc,'Input_method_line','DeltaFreq:');
    bw=set(bw,'constant_line','DF/reps:');
    flank=add_to_comp_list(flank,'Freq_comp',fc);
    flank=add_to_comp_list(flank,'Freq_comp',bw);
case 1
	if (isa(varargin{1},'FLANKING_BAND_CO'))
	    flank = varargin{1}; 
    end
otherwise
    treat_error('Wrong input argument to FLANKING_BAND_CO constructor');
end 