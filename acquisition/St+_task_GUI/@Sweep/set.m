function swp = set(swp,varargin)
% SET Set Sweep properties and return the updated object
% Property names are:
% Sdata, Sdata_formula, Edata, Edata_formula, Num_data, Num_data_formula, 
% Reps, Reps_formula, Mode, Step.

orig_swp=swp;
property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
       error(['The property input is not a valid Sweep property'])
    end 
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
        case {'Sdata_formula','Edata_formula','Num_data_formula','Reps_formula'}
            if (~isa(val,'char'))
                error('The value must be of type char');
            end
    end
            
	switch prop
		case 'Sdata'
		    swp.sdata= val;
		case 'Sdata_formula'
	    	swp.sdata_formula= val;
		case 'Edata'
		    swp.edata= val;
		case 'Edata_formula'
	        swp.edata_formula= val;
		case 'Num_data'
			    swp.num_data= val;
			    swp.seq_length=swp.num_data*swp.reps;
		case 'Num_data_formula'
	    	swp.num_data_formula= val;
		case 'Reps'
			    swp.reps= val;
			    swp.seq_length=swp.num_data*swp.reps;
		case 'Reps_formula'
		    swp.reps_formula= val;
		case 'Mode'
		    swp.mode = val;
		case 'Step'
	    	swp.step= val;  
		otherwise
	    	error([prop,' is not a valid Sweep property']);
	end
end
result=check_params('Sdata',swp.sdata,'Edata',swp.edata,...
    'Num_data',swp.num_data,'Reps',swp.reps,'Mode',swp.mode,'Step',swp.step);
if ~result
    swp=orig_swp;
end