function lowpass=LOWPASS(varargin)
%   lowpass class constructor.

switch nargin
case 0
% if no input arguments, create a default object
env=Envelope('LOWPASS');
lowpass.num_of_comps=2;
lowpass=class(lowpass,'LOWPASS',env);
lowpass=add_to_comp_list(lowpass,'Freq_comp',Freq_comp(50));

case 1
   if (isa(varargin{1},'LOWPASS'))
       lowpass = varargin{1}; 
   end
    
otherwise
  treat_error('Wrong input argument to LowPass constructor');
end 




