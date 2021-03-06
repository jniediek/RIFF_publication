function gap = set(gap,varargin)
% SET Set GAP properties and return the updated object
% Property names are:
% STime_comp, ETime_comp, Ramp_comp.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid GAP property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    gap.Envelope=set(gap.Envelope,prop,val); 
end
