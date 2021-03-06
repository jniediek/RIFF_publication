function m_sig=add_to_comp_list(m_sig,comp_type,comp)
% ADD_TO_COMP_LIST adds a component to the given Main Signal components
% list
% M_SIG=ADD_TO_COMP_LIST( M_SIG,COMP_TYPE,COMP)  adds the given component 
% to the given Main Signal components list and the given component name to
% the given Main Signal component names list. It returs the Main Signal
% after the changes.
% The given component must be of type comp_type

if nargin<3
    treat_error('Not enough input arguments');
end

if (~isa(comp_type,'char') || isempty(comp_type))
    treat_error('Component name must be a character array');
end 

if (~(isa(comp,comp_type)) || ~((isa(comp,'Sig_comp')) || (isa(comp,'String_comp'))))
  treat_error(['Component must be of type Sig_comp-->',comp_type]);
end   

m_sig.comp_list_str={m_sig.comp_list_str{:},comp_type};% an array of the components represented by strings
m_sig.comp_list={m_sig.comp_list{:},comp};% an array of the components 
