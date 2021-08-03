function comp = Trial_dur_comp(varargin)
%   Trial_dur_comp class constructor.
%   c=Trial_dur_comp(STATIC_VALUE) creates a Trial_dur_comp object which is a
%   Signal component representing it's  Trial duration.

global TRIAL_DUR_COMP_DEFAULT;
TRIAL_DUR_COMP_DEFAULT=500;

if nargin==0
    comp.name='Trial_dur_comp';
    s_comp=Sig_comp(TRIAL_DUR_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Trial dur:');
    s_comp=set(s_comp,'constant_line','');
    comp=class(comp,'Trial_dur_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'Trial_dur_comp'))
        comp = varargin{1};
        if ~isa(comp.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(comp.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Trial dur:');
            s_comp=set(s_comp,'constant_line','');
            comp.Sig_comp=s_comp;
        end
    else
        comp.name='Trial_dur_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Trial dur:');
        s_comp=set(s_comp,'constant_line','');
        comp=class(comp,'Trial_dur_comp',s_comp);
        if ~(is_legal_trial_dur(comp,varargin{1}))
            treat_error('The given value is not a legal Trial-duration');
        end
    end

else
    treat_error('Wrong number of input arguments for Trial_dur_comp');
end