function lowpass = set(lowpass,varargin)
% SET Set lowpass properties and return the updated object
% Property names are:
% Freq_comp, Phase_comp.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid lowpass property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    lowpass.Envelope=set(lowpass.Envelope,prop,val); 
end
