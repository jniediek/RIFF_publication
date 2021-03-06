function stime = STime_comp(varargin)
%    STime_comp_comp class constructor.
%   c= STime_comp_comp(STATIC_VALUE) creates a  STime_comp object which is a
%   Signal component representing it's  stimulation start time.

global STIME_COMP_DEFAULT;
STIME_COMP_DEFAULT=200;

if nargin==0
    stime.name='STime_comp';
    s_comp=Sig_comp(STIME_COMP_DEFAULT);
    s_comp=set(s_comp,'Input_method_line','Ramp st.:');
    s_comp=set(s_comp,'constant_line','stime/reps:');
    stime=class(stime,'STime_comp',s_comp);

elseif nargin==1
    if (isa(varargin{1},'STime_comp'))
        stime = varargin{1};
        if ~isa(stime.Sig_comp,'Sig_comp')
            s_comp=Sig_comp(stime.Sig_comp);
            s_comp=set(s_comp,'Input_method_line','Ramp st.:');
            s_comp=set(s_comp,'constant_line','stime/reps:');
            stime.Sig_comp=s_comp;
        end
    else
        stime.name='STime_comp';
        s_comp=Sig_comp(varargin{1});
        s_comp=set(s_comp,'Input_method_line','Ramp st.:');
        s_comp=set(s_comp,'constant_line','stime/reps:');
        stime=class(stime,'STime_comp',s_comp);
        if ~(is_legal_stime(stime,varargin{1}))
            treat_error('The given value is not a legal Start-time');
        end
    end

else
    treat_error('Wrong number of input arguments for STime_comp');
end