function l_coord = Line_coordinator(varargin)
%   SIG_COORDINATOR class constructor.
%   L_COORD = LINE_COORDINATOR(BASIC_LINE) constructs a Line Coordinator
%   for the given Basic Line. 

switch nargin
case 0
	l_coord.line=Basic_line;
	coord=Coordinator(l_coord.line);
	l_coord=class(l_coord,'Line_coordinator',coord);

case 1  
	if (isa(varargin{1},'Line_coordinator'))
	    l_coord = varargin{1}; 
	else
		if (isa(varargin{1},'Basic_line'))
		    l_coord.line=varargin{1};
		    coord=Coordinator(varargin{1});    
		    l_coord=class(l_coord,'Line_coordinator',coord);
		else
		    treat_error('Wrong input for Line_coordinator. Usage: Line_coordinator(<Basic_line>)');
		end
	end

otherwise
    treat_error('Wrong number of input arguments for Line_coordinator. Usage: Line_coordinator(Basic_line)');
end
