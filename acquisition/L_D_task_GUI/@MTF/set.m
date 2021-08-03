function mtf = set(mtf,varargin)
% SET Set MTF properties and return the updated object
% Property names are:
% Freq_comp, Phase_comp, Depth_comp.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid MTF property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    mtf.Envelope=set(mtf.Envelope,prop,val); 
end
