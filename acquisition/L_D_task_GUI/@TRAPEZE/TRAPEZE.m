function trapeze=TRAPEZE(varargin)
%   NEW_ENV class constructor.

switch nargin
    case 0
        % if no input arguments, create a default object
        env=Envelope('TRAPEZE');
        trapeze.num_of_comps=4;
        trapeze=class(trapeze,'TRAPEZE',env);
        trapeze=add_to_comp_list(trapeze,'Freq_comp',Freq_comp(10));
        trapeze=add_to_comp_list(trapeze,'Phase_comp',Phase_comp);
        trapeze=add_to_comp_list(trapeze,'Depth_comp',Depth_comp);
        dc=Depth_comp(0.5);
        dc=set(dc,'Input_method_line','Duty Cyc.:');
        dc=set(dc,'constant_line','DC/reps:');
        trapeze=add_to_comp_list(trapeze,'Depth_comp',dc); % Duty cycle

    case 1
        if (isa(varargin{1},'TRAPEZE'))
            trapeze = varargin{1};
        end

    otherwise
        treat_error('Wrong input argument to TRAPEZE constructor');
end




