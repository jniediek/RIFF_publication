function  mtf=MTF(varargin)
%   MTF class constructor.

switch nargin
case 0
% if no input arguments, create a default object
env=Envelope('MTF');
mtf.num_of_comps=3;
mtf=class(mtf,'MTF',env);
mtf=add_to_comp_list(mtf,'Freq_comp',Freq_comp(20));
mtf=add_to_comp_list(mtf,'Phase_comp',Phase_comp);
mtf=add_to_comp_list(mtf,'Depth_comp',Depth_comp);

case 1
   if (isa(varargin{1},'MTF'))
        mtf = varargin{1}; 
   end
    
otherwise
  treat_error('Wrong input argument to MTF constructor');
end 




