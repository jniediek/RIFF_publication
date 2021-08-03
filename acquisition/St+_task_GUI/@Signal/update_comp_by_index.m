function sig= update_comp_by_index(sig,index,input_method,varargin)
% UPDATE_COMP updates the given componentof the Signal with the given input
% method.
% UPDATE_COMP(SIG,COMP_NAME,INPUT_METHOD,VARARGIN) updates the relevant component
% (according to comp_name) with the given input method ('STATIC_VALUE', 'SWEEP',or
% 'SEQ_VALUES') and with the given parameters.
% SIG=UPDATE_COMP(SIG,COMP_NAME,'STATIC_VALUE',VALUE,REPETETIONS) sets the static_value of comp to
% be the given value and  static_reps to be the given repetition and returns the signal after the change.
% SIG=UPDATE_COMP(SIG,COMP_NAME,'SWEEP',SDATA,EDATA,NUM_DATA,REPS,MODE,STEP)
% sets the sweep data member of comp according to the given parameters and
% returns the signal after the change.
% SIG=UPDATE_COMP(SIG,COMP_NAME,'SEQ_VALUES',VALUES_ARR) sets the sequenced values of
% comp to the given array of values and returns the signal after the
% change.
% COMP_NAME should be one of the components names this Signal contains.

if (nargin<3)
    treat_error('Not enough input arguments to Signal/update_comp');
end

num_comps=get(sig,'Num_of_comps');
if (num_comps==0)
    treat_error('The given Signal is not a concrete Signal and it has no components');
end
if index>num_comps
    treat_error(['No signal comp at index=' num2str(index)]);
end

if ( ~isa(input_method,'char'))
    treat_error('Input-method inputs must be of type char');
end

comp=get_comp_by_index(sig,index);
if nargin==3 %only changing input_method property
    comp=set(comp,'Input_method',input_method);
    switch input_method
        case 'STATIC_VALUE'
            comp=set(comp,'Fixed_num_data',get(comp,'Static_reps'));
        case 'SWEEP'
            swp=get(comp,'Sweep');
            comp=set(comp,'Fixed_num_data',get(swp,'Num_data'));
        case 'SEQ_VALUES'
            comp=set(comp,'Fixed_num_data',length(get(comp,'Seq_values')));
    end
    sig=set_comp_by_index(sig,comp,index);
    return;
end
comp=get_comp_by_index(sig,index);

switch input_method
    case 'STATIC_VALUE'
        if (nargin==5 && length(varargin)==2)
            comp=update_input_method(comp,input_method,varargin{:});
        else
            treat_error('Wrong number of arguments for Signal/update_comp');
        end

    case 'SWEEP'
        if (nargin==9 && length(varargin)==6)
            comp=update_input_method(comp,input_method,varargin{:});
        else
            treat_error('Wrong number of arguments for Signal/update_comp');
        end

    case 'SEQ_VALUES'
        if (nargin==4 && length(varargin{:})>=1)
            comp=update_input_method(comp,input_method,varargin{:});
        else
            treat_error('Wrong number of arguments for Signal/update_comp');
        end

    otherwise
        error('Input method must be one of the following:  STATIC_VALUE, SWEEP, SEQ_VALUES');
end

sig=set_comp_by_index(sig,comp,index);
