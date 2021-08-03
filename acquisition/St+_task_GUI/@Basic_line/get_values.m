% function values=get_values(line,num_groups,group_num_trials,comp,crid)
% num_data=get(line,'Line_num_of_trials');
% mult=1;%multiply each value
% if ~(crid==num_groups)
% for k=crid+1:num_groups
% num=group_num_trials(k);
% mult=mult*num;
% end
% end
% 
% times=1;% how many times to repeat the generation of values
% if ~(crid==1)
% for k=1:crid-1
% num=group_num_trials(k);
% times=times*num;
% end
% end
% 
% final_vect=zeros(1,num_data);
% counter=0;
% num_values=0;
% while num_values<num_data
%     len=get(comp,'Fixed_num_data');
%     big_vect=zeros(1,mult*len*times);%k-times
% for k=1:times
% tval=get_trial_values(comp);
% temp_vect=zeros(1,length(tval)*mult);
% for n=1:length(tval);
% tmp=linspace(tval(n),tval(n),mult);
% temp_vect(mult*(n-1)+1:n*mult)=tmp;
% end
% index=((k-1)*mult*n)+1;
% big_vect(index:mult*n*k)=temp_vect;
% end%for
% final_vect(mult*n*k*counter+1:mult*n*k*(counter+1))=big_vect;
% counter=counter+1;
% num_values=k*length(tval)*mult*counter;
% % if k*n*mult>num_data
% %     break;
% % end
% end%while
% values=final_vect(1:num_data);
% 
