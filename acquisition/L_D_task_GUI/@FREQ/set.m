function freq = set(freq,varargin)
% SET Set FREQ properties and return the updated object
% Property names are:
% Level_comp, STime_comp, ETime_comp, Ramp_comp, Freq_comp, Envelope_list.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid FREQ property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    freq.Main_signal=set(freq.Main_signal,prop,val);    
end
     