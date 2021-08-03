function s_comp = set(s_comp,varargin)
% SET Set Sig_comp properties and return the updated object
% Property names are:
% Input_method, Static_value, Value_formula, Static_reps, Reps_formula,
% Seq_values, Seq_values_str, Coord_index, Index_formula, Wrap, Sweep.

global STRING_METHODS;
STRING_METHODS={'STRING','SEQ_VALUES'};

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
        treat_error('The property input is not a valid Signal-component property')
    end
    val = property_argin{2};
    property_argin = property_argin(3:end);

    switch prop
        case {'Value_formula','Reps_formula','Index_formula'}
            if (~isa(val,'char'))
                treat_error('The value must be of type char');
            end
    end

    switch prop
        case 'Input_method'
            if ~(isa(val,'char'))
                treat_error('Input_method must be STRING or SEQ');
            end
             input_m=strcmp(val,STRING_METHODS);
            if ~any(input_m)
                treat_error('Input_method must be STRING or SEQ');
            else
                s_comp.input_method=val;
            end
  

        case 'Static_value'
            if ~ischar(val)
                treat_error('Value must be a string');
            else
                s_comp.static_value = val;
            end

        case 'Static_reps'
            max_trials=get(s_comp,'SIGNAL_MAX_TRIALS');
            val=str2double(val);
            if (~isint(val) || val<1 || val>max_trials)
                treat_error(['Static_reps can hold only positive integer in the range: (1-',num2str(max_trials),')']);
            else
                s_comp.fixed_num_data=val;
                s_comp.static_reps=val;
            end

        case 'Reps_formula'
            s_comp.reps_formula = val;
            
        case {'Seq_values','Seq_values_str'}
            if ~(iscellstr(val))
                treat_error('Seq_values_str must be a cell array of strings');
            end
            s_comp.seq_values_str = val;
            s_comp.fixed_num_data = length(val);

        case 'Fixed_num_data'
%             val=str2double(val);
            if (~isint(val) || val<1)
                treat_error('Fixed_num_data can hold only positive integer');
            else
                s_comp.fixed_num_data=val;
            end

        case 'Coord_index'
              val=str2double(val);
            if (~isint(val) || val<0)
                treat_error('Coord_index can hold only positive integer');
            else
                s_comp.coord_index= val;
                %         s_comp.index_formula =num2str(val);
            end

        case 'Index_formula'
            s_comp.index_formula = val;

        case 'Input_method_line'
            if ~ischar(val)
                treat_error('Input_method_line must be s tring');
            end
            s_comp.Input_method_line = val;

        case 'constant_line'
            if ~ischar(val)
                treat_error('constant_line must be s tring');
            end
            s_comp.constant_line = val;

        case 'Wrap'
            if (~(isint(val)))
                treat_error('Wrap must be 0 or 1');
            end
            if ~(any(val==[0 1]))
                treat_error('Wrap must be 0 or 1');
            else
                s_comp.wrap= val;
            end

        otherwise
            treat_error([prop,' is not a string_comp property']);
    end
end