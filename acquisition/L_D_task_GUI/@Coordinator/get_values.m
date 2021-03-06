function values=get_values(coord,comp,crid)
% GET_VALUES returns the table of values of the component.
% VALUES=GET_VALUES(COORD,COMP,CRID) returns the table of 
% values of the given component.
% CRID is the coordination index that define the  order that the
% values of this component will be taken relative to the other components.
% For example if comp1 has CRID=1 and 2 values and comp2 has CRID=2 and 5
% values (total trials=2*5=10) then the generation of values will be the following:
% for comp1 : val-1,val-1,val-1,val-1,val-1,val-2,val-2,val-2,val-2,val-2
% for comp1 : val-1,val-2,val-3,val-4,val-5,val-1,val-2,val-3,val-4,val-5
% The table of value is a table of size (1 x total-trials) where 
% cell k holds the value for the k trial.
% The number of trials for the specific component might be less than the
% total trials (if wrapped or cartezic product) so the coordinator fill 
% in the right values through the coordination process.
% For example : if table1=[10 12 33 45] then there are 4 trials and the values
% that will be set for that component for the 4 trials will be 10, 12, 33
% and 45

if nargin<3
  treat_error(['Not enough input arguments for Coordinator/get_values']);
end 

if (~(isa(comp,'Sig_comp')))
  treat_error(['Wrong input - Component must be of type Sig_comp']);
end  

if (~isint(crid) ||  crid<1)
    treat_error('Illegal crid input for Coordinator/get_values');
end

if ~(get(coord,'Valid'))
    treat_error('The coordinated object is not valid');
end

num_groups=get(coord,'Num_coord_groups');
if (~isint(crid) || crid>num_groups)
    treat_error(['Wrong input - illegal crid']);
end  

num_data=get(coord,'Total_trials');
group_num_trials=get(coord,'Group_num_trials');
group_wrap=get(s_coord,'Group_wrap');

mult=1;%multiply each value
if ~(crid==num_groups)
	for k=crid+1:num_groups
        if ~(group_wrap(k))
	        num=group_num_trials(k);
	        mult=mult*num;
        end
   end
end

times=1;% how many times to repeat the generation of values
if ~(crid==1)
	for k=1:crid-1
        if ~(group_wrap(k))
	        num=group_num_trials(k);
	        times=times*num;
        end
	end
end

final_vect=zeros(1,num_data);
counter=0;
num_values=0;
while num_values<num_data
	len=get(comp,'Fixed_num_data');
	big_vect=zeros(1,mult*len*times);%k-times
	for k=1:times
		tval=get_trial_values(comp);
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

