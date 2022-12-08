function  rx8=RX8(varargin)

switch nargin
	case 0
		% if no input arguments, create a default object
        rx8.device_num=1;
        rx8.controler=actxcontrol('RPco.x',[5 5 26 26]);
		rx8=class(rx8,'RX8');
	
	case 1
		if (isa(varargin{1},'RX8'))
		    rx8 = varargin{1}; 
		else
% 		    treat_error('Input argument is not a rp2x object');
% 		end
           rx8.device_num=varargin{1};
            rx8.controler=actxcontrol('RPco.x',[5 5 26 26]);
            rx8=class(rx8,'RX8'); 
        end
        
	otherwise
	    treat_error('Wrong input argument to RX8 constructor');
end