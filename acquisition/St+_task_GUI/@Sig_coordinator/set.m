function s_coord = set(s_coord,varargin)
% SET Set Sig_coordinator properties and return the updated object
% Property names are:
% Main_signal.
property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid Sig_coordinator property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
  switch prop
      case 'Main_signal'
          if (isa(val,'Main_signal'))
                s_coord.m_sig=val;
          else
                treat_error('Wrong input to Sig_coordinator/set - the input must be of type Main_signal');
          end
          
	otherwise
        s_coord.Coordinator=set(s_coord.Coordinator,prop,val);
    end
end