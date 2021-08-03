function comp = Depth_comp(varargin)
%   Depth_comp class constructor.
%   c=Depth_comp(STATIC_VALUE) creates a Depth_comp object which is a
%   Signal component representing it's  Depth.

global DEPTH_COMP_DEFAULT;
DEPTH_COMP_DEFAULT=1;

if nargin==0
    comp.name='Depth_comp';
    s_comp=Sig_comp(DEPTH_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Depth:');
    s_comp=set(s_comp,'constant_line','depth/reps:');
    comp=class(comp,'Depth_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'Depth_comp'))
        comp = varargin{1};
        if ~isa(comp.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(comp.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Depth:');
            s_comp=set(s_comp,'constant_line','depth/reps:');
            comp.Sig_comp=s_comp;
        end
    else
        comp.name='Depth_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Depth:');
        s_comp=set(s_comp,'constant_line','depth/reps:');
        comp=class(comp,'Depth_comp',s_comp);
        if ~(is_legal_depth(comp,varargin{1}))
            treat_error('The given value is not a legal Depth');
        end
    end

else
    treat_error('Wrong number of input arguments for Depth_comp');
end


