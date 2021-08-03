function env=add_to_comp_list(env,comp_type,comp)
% ADD_TO_COMP_LIST adds a component to the given  Envelope components
% list
% ENV=ADD_TO_COMP_LIST(ENV,COMP_TYPE,COMP)  adds the given component 
% to the given Envelope components list and the given component name to
% the given Envelope component names list. It returns the Envelope
% after the changes.
% The given component must be of type comp_type

num_of_comps=get(env,'Num_of_comps');
if ~(strcmp(class(env),'Envelope'))
	if nargin<3
        treat_error('Not enough input arguments');
	end
	
	if (~isa(comp_type,'char') || isempty(comp_type))
        treat_error('Component name must be a character array');
	end 
	
	if (~(isa(comp,comp_type)) || ~(isa(comp,'Sig_comp')))
      treat_error(['Component must have the hierarchy structure of : Sig_com-->',comp_type]);
	end   
	
	env.comp_list_str={env.comp_list_str{:},comp_type};% an array of the components represented by strings
	env.comp_list={env.comp_list{:},comp};% an array of the components 
    
else
treat_error('This is not a concrete envelope and therefor components can not be added');
end
