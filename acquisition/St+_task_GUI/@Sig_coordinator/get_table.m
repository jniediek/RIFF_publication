function trials_table= get_table(s_coord,rnd_builder)
% GET_TABLE returns the table of values of all components.
% TRIALS_TABLE=GET_TABLE(S_COORD,RND_BUILDER) returns the table of
% values of all components.
% RND_BUILDER is a 2-rows cell array that holds for each crid
% the  random order of choosing it's  values (used for components
% with swept-values and mode=RND) .
% The first row of the cell array holds the CRIDS (coordination index) of the
% components and the second row hold for every matching CRID the random order of
% choosing the component's values. This way the values of components with the
% same CRID will be chosen in the same random order.
% For examle:
% Consider that  s-coords coordinates a signal with 4 components with the
% following data:
% 1. Level_comp - input_method=SWEEP , 10 values in range 90-100, mode=RND,
% crid=0
%
% 2. STime_comp - input_method=SWEEP , 5 values in range 100-200, mode=RND,
% crid=1
%
% 3. ETime_comp - input_method=SWEEP , 5 values in range 900-1000, mode=RND
% crid=1
%
% 4. Ramp_comp - input_method=SWEEP , 3 values in range 10-20, mode=RND
% crid=5
%
%  One legal option for RND_BUILDER ={0,1,5 ; [9 7 2 5 6 8 4 3 1 10],[3 4 2 5 1],[2 3 1]}
% That means for example, that STime_comp & ETime_comp values will be
% taken in the order : ninth value, seventh value, second value , and so
% on.
%
%  Another legal option for RND_BUILDER ={1,0,5 ; [5 3 2 4 1],[9 7 2 5 6 8 4 3 1 10],[1 2 3]}
% The first row of RND_BUILDER must hold all the crids of groups that
% contains a component with swept values and MODE=RND
% Each cell in the second row must hold a permutation array from 1 to the number
% of trials defined by the relevant group.
%
%  Another legal option for RND_BUILDER ={1,0,5,3,4,6 ; [5 3 2 4 1],[9 7 2 5 6 8 4 3 1 10],[1 2 3],9,9,9}
% since the cell array is not limited in the number of collumns as long as
% all the groups that contain a component with swept values and MODE=RND
% has a representation in the array.
%
% The returned value - the table of values is a table of size
% (number-of-components  x total-trials) where each row k holds the values
% of all trials for component k .

comp_list=get(s_coord, 'Components');
rows=length(comp_list);
col=get(s_coord,'Total_trials');
table=cell(rows,col);
crid_list=get(s_coord,'Coord_indices');
original_crid_list=get(s_coord,'Old_coord_indices');

for k=1:rows
    comp=comp_list{k};
    crid=crid_list(k);
    original_crid=original_crid_list(k);
    tmp=get_values(s_coord,comp,crid,original_crid,rnd_builder);
    if isa(comp,'SIG_COMP')
        for jj=1:col,
            table{k,jj}=tmp(jj);
        end
    elseif isa(comp,'STRING_COMP')
        for jj=1:col,
            table{k,jj}=tmp{jj};
        end
    end
end
trials_table=table;
%%%%%%%%%%%%%%%%%%%%%%% subfunction %%%%%%%%

function values=get_values(s_coord,comp,crid,original_crid,rnd_builder)
total_trials=get(s_coord,'Total_trials');
num_groups=get(s_coord,'Num_coord_groups');
group_num_trials=get(s_coord,'Group_num_trials');
group_wrap=get(s_coord,'Group_wrap');

mult=1;%multiply each value
if ~(crid==num_groups)
    for k=crid+1:num_groups
        if (~(group_wrap(k)) || all(group_wrap))
            num=group_num_trials(k);
            mult=mult*num;
        end
    end
end

times=1;% how many times to repeat the generation of values
if ~(crid==1)
    for k=1:crid-1
        if (~(group_wrap(k)) || all(group_wrap))
            num=group_num_trials(k);
            times=times*num;
        end
    end
end

if isa(comp,'SIG_COMP')
    final_vect=zeros(1,total_trials);
    counter=0;
    num_values=0;
    while num_values<total_trials
        len=get(comp,'Fixed_num_data');
        big_vect=zeros(1,mult*len*times);%k-times
        for k=1:times
            if ((get(comp,'Input_method_flag')==2) && (get(comp,'Wrap')==0)) % a SWEEP
                swp=get(comp,'Sweep');
                tval=[];
                if( strcmp(get(swp,'Mode'),'SEQ')==1)
                    tval=get_trial_values(comp);
                elseif( strcmp(get(swp,'Mode'),'RND')==1)
                    if ~(isempty(rnd_builder))
                        crids_row=cell2mat(rnd_builder(1,:));
                        match=find(crids_row==original_crid);
                        tval=get_trial_values(comp,rnd_builder{2,match});
                    else
                        tval=get_trial_values(comp);
                    end
                end
            else % not SWEEP
                tval=get_trial_values(comp);
            end
            temp_vect=zeros(1,length(tval)*mult);
            for n=1:length(tval);
                tmp=tval(n)*ones(1,mult); % linspace(tval(n),tval(n),mult);
                temp_vect(mult*(n-1)+1:n*mult)=tmp;
            end
            index=((k-1)*mult*n)+1;
            big_vect(index:mult*n*k)=temp_vect;
        end%for
        final_vect(mult*n*k*counter+1:mult*n*k*(counter+1))=big_vect;
        counter=counter+1;
        num_values=k*length(tval)*mult*counter;
    end%while
    values=final_vect(1:total_trials);
elseif isa(comp,'STRING_COMP')
    final_vect=cell(1,total_trials);
    counter=0;
    num_values=0;
    while num_values<total_trials
        len=get(comp,'Fixed_num_data');
        big_vect=cell(1,mult*len*times);%k-times
        for k=1:times
            tval=get_trial_values(comp);
            temp_vect=cell(1,length(tval)*mult);
            for n=1:length(tval);
                for mm=1:mult
                    temp_vect{mult*(n-1)+mm}=tval{n};
                end
            end
            index=((k-1)*mult*n)+1;
            for ii=index:mult*n*k
                big_vect{ii}=temp_vect{ii-index+1};
            end
        end%for
        for ii=1:length(big_vect)
            final_vect{mult*n*k*counter+ii}=big_vect{ii};
        end
        counter=counter+1;
        num_values=k*length(tval)*mult*counter;
    end%while
    values=final_vect(1:total_trials);
end

