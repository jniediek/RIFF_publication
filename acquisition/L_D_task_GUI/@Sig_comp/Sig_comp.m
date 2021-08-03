function s_comp = Sig_comp(varargin)
%   Sig_comp class constructor.
%   s=Sig_comp(STATIC_VALUE) creates a Sig_comp object which represents a
%   Signal component.
%   Sig_comp is the base class of all numerical signal components (Level_comp, Freq_comp ...etc)
%   and static value is the value of the Signal component that this object
%   represents.

global INPUT_METHOD_DEF;
global INPUT_METHODS;

INPUT_METHODS={'STATIC_VALUE','SWEEP','SEQ_VALUES'};
INPUT_METHOD_DEF=INPUT_METHODS{1,1};

switch nargin
    case 0
        s_comp.name='Sig_comp';
        s_comp.input_method=INPUT_METHOD_DEF;
        s_comp.static_value=0;
        s_comp.value_formula=num2str(0);
        s_comp.static_reps=1;
        s_comp.reps_formula='1';
        s_comp.seq_values=1;
        s_comp.seq_values_str={'1'};
        s_comp.coord_index=0;
        s_comp.index_formula={};
        s_comp.wrap=1;
        s_comp.fixed_num_data=s_comp.static_reps;
        s_comp.Sweep=Sweep;
        s_comp.Input_method_line='CompParam: ';
        s_comp.constant_line='Param/reps: ';
        s_comp=class(s_comp,'Sig_comp');

    case 1
        if (isa(varargin{1},'Sig_comp'))
            s_comp = varargin{1};
        elseif isstruct(varargin{1})
            s_comp.name='Sig_comp';
            s_comp.input_method=INPUT_METHOD_DEF;
            s_comp.static_value=0;
            s_comp.value_formula='0';
            s_comp.static_reps=1;
            s_comp.reps_formula='1';
            s_comp.seq_values=1;
            s_comp.seq_values_str={'1'};
            s_comp.coord_index=0;
            s_comp.index_formula={};
            s_comp.wrap=1;
            s_comp.fixed_num_data=s_comp.static_reps;
            s_comp.Sweep=Sweep;
            s_comp.Input_method_line='CompParam: ';
            s_comp.constant_line='Param/reps: ';
            flist=fields(varargin{1});
            f2u=fields(s_comp);
            for iff=1:length(flist)
                ind=strmatch(flist{iff}, f2u, 'exact');
                if ~isempty(ind)
                    s_comp.(flist{iff})=varargin{1}.(flist{iff});
                end
            end
            s_comp=class(s_comp,'Sig_comp');
        elseif ischar(varargin{1})
            s_comp.name='Sig_comp';
            s_comp.input_method=INPUT_METHOD_DEF;
            s_comp.static_value=varargin{1};
            s_comp.value_formula=varargin{1};
            s_comp.static_reps=1;
            s_comp.reps_formula='1';
            s_comp.seq_values=1;
            s_comp.seq_values_str={'1'};
            s_comp.coord_index=0;
            s_comp.index_formula={};
            s_comp.wrap=1;
            s_comp.fixed_num_data=s_comp.static_reps;
            s_comp.Sweep=Sweep;
            s_comp.Input_method_line='CompParam: ';
            s_comp.constant_line='Param/reps: ';
            s_comp=class(s_comp,'Sig_comp');
        elseif  ~(length(varargin{1})==1)
            treat_error('The input arguments is not a single double');
        elseif (isa(varargin{1},'double'))
            s_comp.name='Sig_comp';
            s_comp.input_method=INPUT_METHOD_DEF;
            s_comp.static_value=varargin{1};
            s_comp.value_formula=num2str(varargin{1});
            s_comp.static_reps=1;
            s_comp.reps_formula='1';
            s_comp.seq_values=1;
            s_comp.seq_values_str={'1'};
            s_comp.coord_index=0;
            s_comp.index_formula={};
            s_comp.wrap=1;
            s_comp.fixed_num_data=s_comp.static_reps;
            s_comp.Sweep=Sweep;
            s_comp.Input_method_line='CompParam: ';
            s_comp.constant_line='Param/reps: ';
            s_comp=class(s_comp,'Sig_comp');
        else
            treat_error('The input arguments is not a Sig_comp object nor a double');
        end
    otherwise
        treat_error('Wrong number of input arguments for Sig_comp. Usage: Sig_comp(argument)')
end