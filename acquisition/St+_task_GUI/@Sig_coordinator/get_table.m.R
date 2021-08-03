function trials_table= get_table(s_coord,rnd_builder)
% GET_TABLE returns the table of values of all components.
% TRIALS_TABLE=GET_TABLE(S_COORD,RND_BUILDER) returns the table of 
% values of all components.
% RND_BUILDER is a (2 x num-of-crids) cell array that holds for each crid
% of a swept-values component with mode=RND, the random order of choosing it's  values.
% For examle: 
% Consider that s-coors coordinates a signal with 4 components with the
% following data:
% 1. Level_comp - input_method=SWEEP , 10 values in range 90-100, mode=RND,
% crid=0
% 2. STime_comp - input_method=SWEEP , 5 values in range 100-200, mode=RND,
% crid=1
% 3. ETime_comp - input_method=SWEEP , 5 values in range 900-1000, mode=RND
% crid=1
% 4. Ramp_comp - input_method=SWEEP , 3 values in range 10-20, mode=RND
% crid=2
%
%   One option for RND_BUILDER ={0,1,2 ; [9 7 2 5 6 8 4 3 1 10],[3 4 2 5 1],[2 3 1]}
% That means for example, that STime_comp & ETime_comp v alues will be
% taken in the order : ninth value, seventh value, second value , and so
% on.
% The table of values is a table of size (number-of-components  x total-trials) where 
% each row k holds the values of all trials for component k .


comp_list=get(s_coord,'Components');
rows=length(comp_list);
col=get(s_coord,'Total_trials');
table=zeros(rows,col);
num_groups=get(s_coord,'Num_coord_groups');
crid_list=get(s_coord,'Coord_indices');

for k=1:rows
comp=comp_list{k};
crid=crid_list(k);
table(k,:)=get_values(s_coord,comp,crid,rnd_builder);
end
trials_table=table;
%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%

function values=get_values(s_coord,comp,crid,rnd_builder)
num_data=get(s_coord,'Total_trials');
num_groups=get(s_coord,'Num_coord_groups');
group_num_trials=get(s_coord,'Group_num_trials');

mult=1;%multiply each value
if ~(crid==num_groups)
	for k=crid+1:num_groups
	    num=group_num_trials(k);
	    mult=mult*num;
	end
end

times=1;% how many times to repeat the generation of values
if ~(crid==1)
	for k=1:crid-1
	    num=group_num_trials(k);
	    times=times*num;
	end
end

final_vect=zeros(1,num_data);
counter=0;
num_values=0;
while num_values<num_data
	len=get(comp,'Fixed_num_data');
	big_vect=zeros(1,mult*len*times);%k-times
	for k=1:times
		swp=get(comp,'Sweep');
		tval=[];
		if( strcmp(get(swp,'Mode'),'SEQ')==1)
		    tval=get_trial_values(comp);
		elseif( strcmp(get(swp,'Mode'),'RND')==1)
		    if ~(isempty(rnd_builder))
		        crid=get(comp,'Coord_index');
		        tmp=rnd_builder{1,:};
                match=find(tmp==crid);     
		        tval=get_trial_values(comp,rnd_builder{2,match});
		    else
		         tval=get_trial_values(comp);
		    end
		end
		temp_vect=zeros(1,length(tval)*mult);
		for n=1:length(tval);
		    tmp=linspace(tval(n),tval(n),mult);
		    temp_vect(mult*(n-1)+1:n*mult)=tmp;
		end
		index=((k-1)*mult*n)+1;
		big_vect(index:mult*n*k)=temp_vect;
	end%for
	final_vect(mult*n*k*counter+1:mult*n*k*(counter+1))=big_vect;
	counter=counter+1;
	num_values=k*length(tval)*mult*counter;
end%while
values=final_vect(1:num_data);

