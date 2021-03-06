function etime = ETime_comp(varargin)
%    ETime_comp_comp class constructor.
%   c= ETime_comp_comp(STATIC_VALUE) creates a  ETime_comp object which is a
%   Signal component representing it's  stimulation end time.

global ETIME_COMP_DEFAULT;
ETIME_COMP_DEFAULT=400;

if nargin==0
    etime.name='ETime_comp';
    s_comp=Sig_comp(ETIME_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Ramp end:');
    s_comp=set(s_comp,'constant_line','etime/reps:');
    etime=class(etime,'ETime_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'ETime_comp'))
        etime = varargin{1};
        if ~isa(etime.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(etime.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Ramp end:');
            s_comp=set(s_comp,'constant_line','etime/reps:');
            etime.Sig_comp=s_comp;
        end
    else
        etime.name='ETime_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Ramp end:');
        s_comp=set(s_comp,'constant_line','etime/reps:');
        etime=class(etime,'ETime_comp',s_comp);
        if ~(is_legal_etime(etime,varargin{1}))
            treat_error('The given value is not a legal End-time');
        end
    end

else
    treat_error('Wrong number of input arguments for ETime_comp');
end