function  env = Envelope(varargin)
%    Envelope class constructor.
%   Envelope(name) constructs an envelope with a given name.
%   Envelope is the base class of all Envelopes (MTF ...etc) .

switch nargin
case 0
	% if no input arguments, create a default object
	name='none';
    env.comp_list={};
    env.comp_list_str={};
	sig=Signal(name);
	env=class(env,'Envelope',sig);

case 1
       if (isa(varargin{1},'Envelope'))
            env = varargin{1}; 
       elseif (isa(varargin{1},'char'))
            name=varargin{1};
            env.comp_list={};
            env.comp_list_str={};
            sig=Signal(name);
            env=class(env,'Envelope',sig);
        else
            treat_error('Input argument is not a Envelope object and not a signal name');
       end
     
otherwise
  treat_error('Wrong input argument to Envelope constructor');
end     


