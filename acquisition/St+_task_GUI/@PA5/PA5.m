function  pa5=PA5(varargin)

switch nargin
	case 0
		% if no input arguments, create a default object
		pa5.device_num=1;
        pa5.controler=actxcontrol('PA5.x',[5 5 26 26]);
        pa5.atten=0;
		pa5=class(pa5,'PA5');
	
	case 1
		if (isa(varargin{1},'PA5'))
		    pa5 = varargin{1}; 
		else
% 		    treat_error('Input argument is not a PA5x object');
% 		end
           pa5.device_num=varargin{1};
            pa5.controler=actxcontrol('PA5.x',[5 5 26 26]);
            pa5.atten=0;
            pa5=class(pa5,'PA5'); 
        end
        
	otherwise
	    treat_error('Wrong input argument to PA5 constructor');
end