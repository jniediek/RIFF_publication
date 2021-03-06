function comp = Freq_comp(varargin)
%    Freq_comp_comp class constructor.
%   c= Freq_comp_comp(STATIC_VALUE) creates a  Freq_comp object which is a
%   Signal component representing it's  frequency.


global FREQ_COMP_DEFAULT;
FREQ_COMP_DEFAULT=1500;

if nargin==0
    comp.name='Freq_comp';
    s_comp=Sig_comp(FREQ_COMP_DEFAULT);
    s_comp=change_sweep_param(s_comp,'Step','LOG');
    s_comp=set(s_comp,'Input_method_line','Frequency:');
    s_comp=set(s_comp,'constant_line','freq/reps:');
    comp=class(comp,'Freq_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'Freq_comp'))
        comp = varargin{1};
        if ~isa(comp.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(comp.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Frequency:');
            s_comp=set(s_comp,'constant_line','freq/reps:');
            comp.Sig_comp=s_comp;
        end
    else
        comp.name='Freq_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=change_sweep_param(s_comp,'Step','LOG');
        s_comp=set(s_comp,'Input_method_line','Frequency:');
        s_comp=set(s_comp,'constant_line','freq/reps:');
        comp=class(comp,'Freq_comp',s_comp);
        if ~(is_legal_freq(comp,varargin{1}))
            treat_error('The given value is not a legal Frequency');
        end
    end

else
    treat_error('Wrong number of input arguments for Freq_comp');
end