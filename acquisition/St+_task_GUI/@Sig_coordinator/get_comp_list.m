function list=get_comp_list(varargin)
% GET_COMP_LIST returns the list of components.
% LIST=GET_COMP_LIST(SIG_COORD) returns the list of
% components of the Main_signal object that the given 
% Signal-coodinator coordinates, including components that consists
% it's Envelopes.
% LIST=GET_COMP_LIST(SIG_COORD,EXTERNAL_COMP) returns the list of 
% components of  the  Main_signal object that the given 
% Signal-coodinator coordinates, including components that consists
% it's Envelopes and also adds an external component to this list
% before returning it.


if nargin==1
main_sig=get(varargin{1},'Main_signal');
list=get_comp_list(main_sig);
elseif nargin==2
  main_sig=get(varargin{1},'Main_signal');  
  list=get_comp_list(main_sig,varargin{2});  
else
    treat_error('Wrong number of arguments for Sig_coordinator/get_comp_list');
end