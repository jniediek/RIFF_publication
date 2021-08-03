function comp = Phase_comp(varargin)
%   Phase_comp class constructor.
%   c=Phase_comp(STATIC_VALUE) creates a Phase_comp object which is a
%   Signal component representing it's  Phase.

global PHASE_COMP_DEFAULT;
PHASE_COMP_DEFAULT=0;

if nargin==0
    comp.name='Phase_comp';
    s_comp=Sig_comp(PHASE_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Phase:');
    s_comp=set(s_comp,'constant_line','phase/reps:');
    comp=class(comp,'Phase_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'Phase_comp'))
        comp = varargin{1};
        if ~isa(comp.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(comp.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Phase:');
            s_comp=set(s_comp,'constant_line','phase/reps:');
            comp.Sig_comp=s_comp;
        end
    else
        comp.name='Phase_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Phase:');
        s_comp=set(s_comp,'constant_line','phase/reps:');
        comp=class(comp,'Phase_comp',s_comp);
        if ~(is_legal_phase(comp,varargin{1}))
            treat_error('The given value is not a legal Phase');
        end
    end

else
    treat_error('Wrong number of input arguments for Phase_comp');
end