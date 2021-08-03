function new_env = set(new_env,varargin)
% SET Set NEW_ENV properties and return the updated object
% Property names are:
% Freq_comp, Phase_comp.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid NEW_ENV property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    new_env.Envelope=set(new_env.Envelope,prop,val); 
end
