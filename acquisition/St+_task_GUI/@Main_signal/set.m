function m_sig = set(m_sig,varargin)
% SET Set Main_signal properties and return the updated object
% Property names are:
% Level_comp, STime_comp, ETime_comp, Ramp_comp, Envelope_list.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid Main_signal property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    
    index=strmatch(prop,m_sig.comp_list_str,'exact');
    if ~isempty(index)
         if ~(isa(val,m_sig.comp_list_str{index}))
             treat_error(['The input is not a ',m_sig.comp_list_str{index}]);
        end
     m_sig.comp_list{index}=val;
     else
        switch prop
        case 'Envelope_list'
           if (isa(val,'cell'))
                 for k=1:length(val)
                      if ~isa(val{k},'Envelope')
                         treat_error('The input contains object not of type Envelope');
                     end%if
                 end%for
            else
              treat_error('The input must be a cell array of type Envelope');   
           end
             m_sig.envelope_list = val;
             m_sig.num_of_env=length(m_sig.envelope_list);
     
		otherwise       
		m_sig.Signal=set(m_sig.Signal,prop,val);
        end
    end
end