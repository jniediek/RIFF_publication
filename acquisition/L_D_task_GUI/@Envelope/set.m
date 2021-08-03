function env = set(env,varargin)
% SET Set Envelope properties and return the updated object
% Property names are the component names that build the relevant Envelope.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid Envelope property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    
    index=strmatch(prop,env.comp_list_str,'exact');
    if ~isempty(index)
         if ~(isa(val,env.comp_list_str{index}))
             treat_error(['The input is not a ',m_sig.comp_list_str{index}]);
         end
         env.comp_list{index}=val;
     end
 end
     