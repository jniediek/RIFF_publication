function sig = Signal(varargin)
% Signal class constructor.
% Signal(name) constructs a signal with a given name.
% Signal is the base class of all signals (BBN, FREQ,MTF ...etc) .

% Creating a new signal:
%
% Creating a new Main_signal (assuming it's name is NEW_SIGNAL):
% 1. Creating a library with the name : @NEW_SIGNAL
% 2. Creating a library with the name : private under @NEW_SIGNAL library.
% 3. Implementing the following methods (appear in all the concrete signals
% (BBN,FREQ..etc) : NEW_SIGNAL.m (the creation m.file), get.m, set.m, synth.m.
% 4. If the Main_signal contain a component that does not  exist- such
%      a component should be created first. 
% 5. Copying the treat_error function to the private library from an existing signal. 
% 6. Adding NEW_SIGNAL to global variable - MAIN_SIGNAL_OPT - in
%     maestro1-->init_GUI
% 7. Adding a branch to the swich command in
%      maestro2-->change_signal_for_channel to deal with NEW_SIGNAL.
%
% Creating a new Envelope (assuming it's name is NEW_ENV):
% 1. Creating a library with the name : @NEW_ENV
% 2. Creating a library with the name : private under @NEW_ENV library.
% 3. Implementing the following methods (appear in all the concrete
%  envelopes (MTF..etc) : NEW_ENV.m (the creation m.file), get.m, set.m, synth.m.
% 4. If NEW_ENV contain any  component it should be added to it's
%    components-list (see MTF creation function - MTF.m)
% 5. Copying the treat_error function to the private library from an existing signal/envelope. 
% 6. Adding NEW_ENV to global variable - ENVELOPE_OPT - in
%     maestro1-->init_GUI
% 7. Adding a branch to the swich command in
%      maestro2-->update_add_vars  to deal with NEW_ENV.
%
%     If the added  NEW_SIGNAL is  reguested also in Search program then do the
%     following:
%     Notice that in search a Main_signal can have maximum 5 components!
% 1. Add NEW_SIGNAL to global variable - SEARCH_SIGNAL_OPT - in
%     search-->init_GUI
% 2. Adding a branch to the swich command in
%      search-->change_signal_for_channel to deal with NEW_SIGNAL
%
%     If the added NEW_ENV is reguested also in Search program then do the
%     following:
%      Notice that in search an Envelope can have maximum 3 components!
% 6. Add  NEW_ENV to global variable - SEARCH_ENVELOPE_OPT - in
%     search-->init_GUI
% 7. Adding a branch to the swich command in
%      maestro2-->update_add_vars  to deal with NEW_ENV.
 switch nargin
case 0
	% if no input arguments, create a default object
	sig.name='Signal'; 
	sig=class(sig,'Signal');

case 1
	if (isa(varargin{1},'Signal'))
	    sig = varargin{1}; 
	elseif (isa(varargin{1},'char'))
		sig.name=varargin{1};
		sig=class(sig,'Signal');
	else
	    treat_error('Input argument is not a Signal object and not a signal name');
    end

otherwise
    treat_error('Wrong number of input arguments for Signal constructor');
end