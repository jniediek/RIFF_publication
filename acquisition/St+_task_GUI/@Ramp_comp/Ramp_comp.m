function ramp= Ramp_comp(varargin)
%   Ramp_comp class constructor.
%   c=Ramp_comp(STATIC_VALUE) creates a Ramp_comp object which is a
%   Signal component representing it's  Ramp.

global RAMP_COMP_DEFAULT;
RAMP_COMP_DEFAULT=10;

if nargin==0
    ramp.name='Ramp_comp';
    s_comp=Sig_comp(RAMP_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Ramp len:');
    s_comp=set(s_comp,'constant_line','len/reps:');
    ramp=class(ramp,'Ramp_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'Ramp_comp'))
        ramp = varargin{1};
        if ~isa(ramp.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(ramp.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Ramp len:');
            s_comp=set(s_comp,'constant_line','len/reps:');
            ramp.Sig_comp=s_comp;
        end
    else
        ramp.name='Ramp_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Ramp len:');
        s_comp=set(s_comp,'constant_line','len/reps:');
        ramp=class(ramp,'Ramp_comp',s_comp);
        if ~(is_legal_ramp(ramp,varargin{1}))
            treat_error('The given value is not a legal Ramp-length');
        end
    end

else
    treat_error('Wrong number of input arguments for Ramp_comp');
end