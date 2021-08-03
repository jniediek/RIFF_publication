function data = get_data(swp)
% get_data(swp) returns an array of values that would be generated for 
% the given Sweep object according to it's STEP,range(SDATA,EDATA) and NUM_DATA.
% data will hold NUM_DATA values between SDATA and EDATA.

if swp.num_data==1
    data=swp.sdata;
    return;
end

index=0:swp.num_data-1;
data=ones(1,swp.num_data);%allocation in advance to improve performance

switch swp.step
	case 'LIN'
    	data=swp.sdata+(swp.edata-swp.sdata)*index/(swp.num_data-1);  
	%sdata or edata can be zero only if mode==LIN so division of zero
	%is avoided.
	case 'LOG'
	    data=swp.sdata*power(swp.edata/swp.sdata,index/(swp.num_data-1)); 
	case '1/LIN'
    	data=1./(1/swp.sdata+(1/swp.edata-1/swp.sdata)*index/(swp.num_data-1));
	case '1/LOG'
    	data=swp.sdata./power(swp.sdata/swp.edata,index/(swp.num_data-1));
	otherwise
	    error('Wrong step\nstep = %s',swp.step)
end