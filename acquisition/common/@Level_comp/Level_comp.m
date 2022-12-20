function comp = Level_comp(varargin)
%    Level_comp_comp class constructor.
%   c= Level_comp_comp(STATIC_VALUE) creates a  Level_comp object which is a
%   Signal component representing it's  level.

global LEVEL_COMP_DEFAULT;
global MAX_LEVEL;
LEVEL_COMP_DEFAULT=50;
MAX_LEVEL=120;

if nargin==0
    comp.name='Level_comp';
    s_comp=Sig_comp(LEVEL_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Level:');
    s_comp=set(s_comp,'constant_line','level/reps:');
    comp=class(comp,'Level_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'Level_comp'))
        comp = varargin{1};
        if ~isa(comp.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(comp.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Level:');
            s_comp=set(s_comp,'constant_line','level/reps:');
            comp.Sig_comp=s_comp;
        end
    else
        comp.name='Level_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Level:');
        s_comp=set(s_comp,'constant_line','level/reps:');
        comp=class(comp,'Level_comp',s_comp);
        if ~(is_legal_level(comp,varargin{1}));
            treat_error('The given value is not a legal Level');
        end
    end

else
    treat_error('Wrong number of input arguments for Level_comp');
end