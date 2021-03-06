function gap=GAP(varargin)
%   GAP class constructor.

switch nargin
case 0
% if no input arguments, create a default object
env=Envelope('GAP');
gap.num_of_comps=3;
gap=class(gap,'GAP',env);
gap=add_to_comp_list(gap,'STime_comp',STime_comp);
gap=add_to_comp_list(gap,'ETime_comp',ETime_comp);
gap=add_to_comp_list(gap,'Ramp_comp',Ramp_comp);

case 1
   if (isa(varargin{1},'GAP'))
       gap = varargin{1}; 
   end
    
otherwise
  treat_error('Wrong input argument to GAP constructor');
end 




