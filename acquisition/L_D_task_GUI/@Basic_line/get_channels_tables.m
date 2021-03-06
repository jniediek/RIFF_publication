function chans_tables= get_channels_tables(line,rnd_builder)
% GET_TABLE returns a cell array of size 4 where each cell holds a tables of
% values of the specific channel. Each such table holds  values of all
% components of the signal in the given channel.
% CHANS_TABLES=GET_TABLE(LINE,RND_BUILDER) returns a cell array of size
% 4 where each cell holds a tables of values of the specific channel. Each
% such table holds  values of all components of the signal in the given
% channel.
% RND_BUILDER is a 2-rows cell array that holds for each crid
% of a swept-values component with mode=RND, the random order of choosing
% it's  values.
% The first row of the cell array holds the CRIDS (coordination index)of the 
% components and the second row hold for every matching CRID the order of 
% choosing the component's values.
% For examle: 
% Consider that the given chan has a signal- coordinator
% of a signal with 4 components with the following data:
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
%  Another legal option for RND_BUILDER ={1,0,5 ; [5 3 2 4 1],[9 7 2 5 6 8 4 3 1 10],[1 2 3]}
% The first row of RND_BUILDER must must hold all the crids of groups that
% contains a component with swept values and MODE=RND
% Each cell in the second row must hold a permutation array from 1 to the number
% of trials defined by the relevant group.
%
%  Another legal option for RND_BUILDER ={1,0,5,3,4,6 ; [5 3 2 4 1],[9 7 2 5 6 8 4 3 1 10],[1 2 3],9,9,9}
% since the cell array is not limited in the number of collumns as long as
% all the groups that contain a component with swept values and MODE=RND
% has a representation in the array.
%
% If RND_BUILDER is empty then the values will be taken randomly without
% any outside interference on the selection.
%
% The returned value - the table of values is a cell array of size 4 that
% contains 4 table for each channel. Every such table holds all the values
% that will be applied for the components when the line is running.
% Each such table is of size : (number-of-components  x total-trials) where
% each row k holds the values of all trials for component k.

new_rnd_builder={{} {} {} {}};

if (~isa(rnd_builder,'cell') && ~isempty(rnd_builder))
    treat_error('Wrong input - RND_BUILDER must be a cell array');
end

s=size(rnd_builder);
if (~(s(1)==2) && ~(isempty(rnd_builder)))
    treat_error('Wrong input - RND_BUILDER must be a cell array with 2 rows');
end

if (~isempty(rnd_builder))
	try
		crids_row=cell2mat(rnd_builder(1,:));
		order_arrays_row=cell2mat(rnd_builder(2,:));
	catch
		treat_error('Wrong input - RND_BUILDER must be a cell array of doubles');
	end
	if (~isa(crids_row,'double') || ~isa(order_arrays_row,'double'))
        treat_error('Wrong input - RND_BUILDER must be a cell array of doubles');
	end
    neg_crids=find(crids_row<0);
    if ~isempty(neg_crids)
       treat_error('Wrong input - RND_BUILDER crids must be positive integers');
    end
    
    for chan=1:4
       chan_list=get(line,'Chan_signals');
       s_coord=chan_list{chan};
       
       if (isempty(s_coord))
            continue;
       end
       
       if (~(get(s_coord,'Valid')==1))
            treat_error('The Signal coordinator is not valid');
       end
        
        group_num_trials=get(s_coord,'Group_num_trials');
        counter=1;
        indices=[];
        indices_loc=[];
        for q=1:length(crids_row)
            if find_crid_in_signal(s_coord,crids_row(q))
                indices(counter)=crids_row(q);
                indices_loc(counter)=q;
                counter=counter+1;
            end
        end
            
        if counter==1
            new_rnd_builder{chan}={};
            continue;
        end
        
        sorted_indices=sort(indices);
        old_coords=get(s_coord,'Old_coord_indices');
       sorted_old_coords=sort(old_coords);
        new_sorted_coords=linspace(-1,-1,length(group_num_trials));
        counter=1;
       for q=1:length(sorted_old_coords)
           if isempty(find(sorted_old_coords(q)==new_sorted_coords)); %removing repeating values
               new_sorted_coords(counter)=sorted_old_coords(q);
               counter=counter+1;
           end
       end

      for k=1:length(indices)
             crid=indices(k);%the relevant crid
            num_rnd_indices=length(rnd_builder{2,indices_loc(k)}); %the number of the generated random values

            if (length(find(crid==indices))>1)
                    treat_error(['Illegal RND_BUILDER - each crid must appear once in the cell array']);
           end
                   
           relative_index=find(crid==new_sorted_coords);%the relative location of the original Signal's crid list
            if (isempty(relative_index))
                treat_error(['The CRID doesnt appear in the signal']);
           end

           group_num_index=group_num_trials(relative_index);%%%%%%%%%%%%%%%
           num_rnd_indices=num_rnd_indices;%%%%%%%%%%%%%%%
           group_wrap=get(s_coord,'Group_wrap');

%                    if (~(group_num_trials(relative_index)==num_rnd_indices) && ~group_wrap(relative_index))
%                        treat_error(['Illegal RND_BUILDER - non appropriate number of random indices for the group',...
%                                ' with crid : ',num2str(crid)]);
%                    end

%                    if ~group_wrap(relative_index)
%                        sorted_rnd_indices=sort(rnd_builder{2,indices_loc(k)});
%                        sorted_correct_indices=(1:1:group_num_trials(relative_index));
%                        if ~all(sorted_rnd_indices==sorted_correct_indices)
% 							treat_error(['Illegal RND_BUILDER - the second row  must hold for each group',...
% 							' a permutation of (1 - number of trial for group)']);
%                         end
%                 end
        end%for
        
        for k=1:length(sorted_indices)
            new_rnd_builder{chan}{1,k}=sorted_indices(k);
            match=find(sorted_indices(k)==indices);
           new_rnd_builder{chan}{2,k}=rnd_builder{2,indices_loc(match)};
        end
    end%for chan=1:4
else
    new_rnd_builder={{} {} {} {}};
end%if (~isempty(rnd_builder))


chan_list=get(line,'Chan_signals');
synth_chans=get(line, 'Synth_chan' );
for chan=1:4
     chans_tables{chan}=[];
end

for chan=1:4
    chan_sig=chan_list{chan};
    if (isempty(chan_sig) || (synth_chans(chan)==0))
        continue;
    end;
    chans_tables{chan}=get_table(chan_sig,new_rnd_builder{chan});
end

chans_tables={chans_tables{1},chans_tables{2},chans_tables{3},chans_tables{4}};
