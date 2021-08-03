function mode_data = get_data_mode(swp,rand_indices_arr)
% mode_data =GET_DATA_MODE (swp,rand_indices_arr) returns 
% an array of randomly chosen values from the vector of values
% generated for the specified Sweep object according to it's STEP,
% range(SDATA,EDATA),NUM_DATA and REPS.
% The order in which the values will appear is random and are selected 
% according to the given randomly generated indices array.

if ~(isa(rand_indices_arr,'double') || isempty(rand_indices_arr))
     error('The given vector isnt a legal vector of indices');
 end
n=length(rand_indices_arr);
temp1=sort(rand_indices_arr);
temp2=(1:1:n);
if (~(temp1==temp2))
    error('The given vector isnt a legal vector of indices');
end
seq_data=get_data_reps(swp);
len=length(seq_data);
tmp_data=zeros(1,len);
counter=1;
unfinished=0;

for k=1:len
    index=rand_indices_arr(counter);
    while (index>len && (counter<(n+1)))%since rand_indices_arr can hold random indices of a bigger array
        counter=counter+1;
        index=rand_indices_arr(counter);
    end
    if (counter==(n+1))
        unfinished=1;
        rest=len-k;
        break;
    end
    tmp_data(k)=seq_data(index);
    if (counter==n)
        unfinished=1;
        rest=len-k-1;
        break;
    end
    counter=counter+1;
end

if (unfinished==1)
    counter=1;
    rand_indices=randperm(rest+1);
    for p=k:k+rest
        index=rand_indices(counter);
        tmp_data(k)=seq_data(index);
        counter=counter+1;
    end
end

mode_data=tmp_data;