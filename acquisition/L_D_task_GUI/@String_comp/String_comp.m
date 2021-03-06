function s_comp = String_comp(varargin)
%   String_comp class constructor.
%   s=String_comp(STATIC_VALUE) creates a String_comp object which represents a
%   string component of the signal.
%   String_comp is the base class of all string-valued signal components (File_comp, )
%   and static value is the value of the String component that this object
%   represents.

global STRING_METHOD_DEF;
global STRING_METHODS;

STRING_METHODS={'STRING','SEQ_VALUES'};
STRING_METHOD_DEF=STRING_METHODS{1,1};

switch nargin
    case 0
        s_comp.name='String_comp';
        s_comp.input_method=STRING_METHOD_DEF;
        s_comp.static_value='';
        s_comp.static_reps=1;
        s_comp.reps_formula='1';
        s_comp.seq_values={''};
        s_comp.seq_values_str={''};
        s_comp.coord_index=0;
        s_comp.index_formula={};
        s_comp.wrap=1;
        s_comp.fixed_num_data=s_comp.static_reps;
        s_comp.Input_method_line='CompParam: ';
        s_comp.constant_line='Param/reps: ';
        s_comp=class(s_comp,'String_comp');

    case 1
        if (isa(varargin{1},'String_comp'))
            s_comp = varargin{1};
        elseif isstruct(varargin{1})
            s_comp.name='String_comp';
            s_comp.input_method=STRING_METHOD_DEF;
            s_comp.static_value='';
            s_comp.static_reps=1;
            s_comp.reps_formula='1';
            s_comp.seq_values={''};
            s_comp.seq_values_str={''};
            s_comp.coord_index=0;
            s_comp.index_formula={};
            s_comp.wrap=1;
            s_comp.fixed_num_data=s_comp.static_reps;
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
            s_comp=class(s_comp,'String_comp');
        elseif ischar(varargin{1})
            s_comp.name='String_comp';
            s_comp.input_method=STRING_METHOD_DEF;
            s_comp.static_value=varargin{1};
            s_comp.static_reps=1;
            s_comp.reps_formula='1';
            s_comp.seq_values={''};
            s_comp.seq_values_str={''};
            s_comp.coord_index=0;
            s_comp.index_formula={};
            s_comp.wrap=1;
            s_comp.fixed_num_data=s_comp.static_reps;
            s_comp.Input_method_line='CompParam: ';
            s_comp.constant_line='Param/reps: ';
            s_comp=class(s_comp,'String_comp');
        elseif  ~ischar(varargin{1})
            treat_error('The input arguments is not a string');
        else
            s_comp.name='String_comp';
            s_comp.input_method=STRING_METHOD_DEF;
            s_comp.static_value=varargin{1};
            s_comp.static_reps=1;
            s_comp.reps_formula='1';
            s_comp.seq_values_str={''};
            s_comp.coord_index=0;
            s_comp.index_formula={};
            s_comp.wrap=1;
            s_comp.fixed_num_data=s_comp.static_reps;
            s_comp.Input_method_line='CompParam: ';
            s_comp.constant_line='Param/reps: ';
            s_comp=class(s_comp,'String_comp');
        end
    otherwise
        treat_error('Wrong number of input arguments for String_comp. Usage: String_comp(argument)')
end