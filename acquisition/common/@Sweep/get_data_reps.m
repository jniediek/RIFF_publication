function reps_data = get_data_reps(swp)
% reps_data =GET_DATA_REPS(swp) returns an array of values that would be generated for 
% this Sweep object .
% The values are generated according to it's STEP,range(SDATA,EDATA),NUM_DATA and REPS.
% Each data will appear reps times in the array returned (total of
% reps*num_data values).

% The raw vector of values before manipulation to produce the requested
% values.
data=get_data(swp);

r=get(swp,'Reps');
r1=linspace(1,1,r);
tmp=linspace(1,1,r);
r=get(swp,'Num_data');
res=data(1).*r1;
 for i=2:r
    tmp=data(i).*r1;
    res=horzcat(res,tmp);
end  
reps_data=res;