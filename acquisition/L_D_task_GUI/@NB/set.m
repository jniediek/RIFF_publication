function nb = set(nb,varargin)
% SET Set NB properties and return the updated object
% Property names are:
% Level_comp, STime_comp, ETime_comp, Ramp_comp, Freq_comp,Freq_comp(for BW),Envelope_list.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       treat_error(['The property input is not a valid NB property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    nb.Main_signal=set(nb.Main_signal,prop,val);
end
fc=get_comp_by_index(nb,5);
bwc=get_comp_by_index(nb,6);
freq=get(fc,'Static_value');
bw=get(bwc,'Static_value');
if freq<bw/2
    treat_error('Bandwidth too large for center frequency');
end