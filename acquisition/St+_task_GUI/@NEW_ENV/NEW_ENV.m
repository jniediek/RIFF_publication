function new_env=NEW_ENV(varargin)
%   NEW_ENV class constructor.

switch nargin
case 0
% if no input arguments, create a default object
env=Envelope('NEW_ENV');
new_env.num_of_comps=3;
new_env=class(new_env,'NEW_ENV',env);
new_env=add_to_comp_list(new_env,'Freq_comp',Freq_comp(20));
new_env=add_to_comp_list(new_env,'Phase_comp',Phase_comp);

case 1
   if (isa(varargin{1},'NEW_ENV'))
       new_env = varargin{1}; 
   end
    
otherwise
  treat_error('Wrong input argument to NEW_ENV constructor');
end 




