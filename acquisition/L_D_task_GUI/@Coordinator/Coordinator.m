function coord = Coordinator(varargin)
%   Coordinator class constructor.
%   COORD = COORDINATOR(MAIN_SIGNAL) constructs a Coordinator
%   for the given Main_signal. 
%   COORD = COORDINATOR(BASIC_LINE) constructs a Coordinator
%   for the given BASIC_LINE.
%   Coordinator is the base class of all Coordinators.
%   The Coordinator coordinates between the different components of it's
%   wrapped object.
%   The coordinator wrapps an object that is built from signal components
%   which each has a coordination index. Components with the same
%   coordination index will belong to the same coordinated group.
%   The Coordination process coordinates between the different components
%   according to their inner data (the coordination index and the wrap
%   indicator) and calculates the total number of trials for the object.
clear coord;
if nargin==0
		coord.components={}; %list of the different components of the wrapped object
		coord.num_of_comp=0; %number of components of the wrapped object
		coord.coord_indices=[0];%list of the indices (used for coordination) of the components of the wrapped object
		coord.num_coord_groups=0;%number of groups of the wrapped object
		coord.old_coord_indices=[0];
		coord.coord_groups={};%list of group-lists - each cell holds the list of components of a coordinated group
		coord.group_wrap=[1];%if equals 1 indicates that all the group components are wrapped (0 if at least one unwrapped)
		coord.valid_group=0;%holds for each group indication if it's a valid group
		coord.group_error='There are no components';%holds for each group an error message if it's an invalid group
		coord.group_num_trials=0;%holds for each group the calculated number of trials 
        %indicates if the whole object is valid (whether the components
        %coordination indices define a possible number of trials senario)
		coord.valid=0;
        %holds the total number of trials after the coordination process
		coord.total_trials=0;
		coord=class(coord,'Coordinator');
       return;
       
   elseif nargin==1
            if (isa(varargin{1},'Coordinator'))
                   coord = varargin{1}; 
                   return;
              else
                  %list of the different components of the wrapped object
                    if (~(isa(varargin{1},'main_signal')) && ~(isa(varargin{1},'basic_line')))
                        treat_error('The input for Coordinator must be a Main_signal or a Basic_line');
                    else
                        coord.components=get_comp_list(varargin{1}); %arg can be main signal or a line
                    end
              end
              
    elseif nargin==2
                     if (~(isa(varargin{1},'main_signal')) || ~(isa(varargin{2},'trial_dur_comp')))
                        treat_error('Wrong input for Coordinator');
                    else
                        coord.components=get_comp_list(varargin{1},varargin{2});
                    end
              
     else
	    treat_error('Wrong number of input arguments for Coordinator. Usage: Coordinator(arg)');
	end
    
% holds the number of total components including those of envelopes
coord.num_of_comp=length(coord.components);
%coord_indices holds the coordination index of each component
comp_indices=zeros(1,coord.num_of_comp);
for index=1:coord.num_of_comp
comp_indices(index)=get((coord.components{index}),'Coord_index');
end
% holds the indices of all the components
coord.coord_indices=comp_indices;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%finding number of coordinated groups(each group is 
%characterized with it's unique coordination index).
tmp=sort(coord.coord_indices);
tmp=[tmp,max(tmp)+1];
index=(1:coord.num_of_comp);
diff=find(tmp(index)<tmp(index+1));
coord.num_coord_groups=length(diff);
diff_values=tmp(diff);%location in tmp of all the different indices
coord.old_coord_indices=coord.coord_indices;
counter=1;
new_indices=linspace(-1,-1,coord.num_coord_groups);
%renumbering the coordination indices so that they will be sequential
for m=1:coord.num_coord_groups
f=find(coord.coord_indices==diff_values(m));
new_indices([f])=counter;
counter=counter+1;
end
coord.coord_indices=new_indices;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% Orginazing groups data %%%%%%%%
%coord_groups holds list of groups - each cell holds 
%the list of components of a coordinated group
for k=1:coord.num_coord_groups
    group_comp_list{k}=coord.components([find(coord.coord_indices==k)]);
end
coord.coord_groups=group_comp_list;

for k=1:coord.num_coord_groups
	group_error{k}={''};
	valid_group(k)=1;
	group_num_trials(k)=0;
	group_wrap(k)=1;
end

%group_wrap(k)=1 only if  all components in group k are wrapped (0 if at least one unwrapped)
for k=1:coord.num_coord_groups
	len=length(coord.coord_groups{k});
	for l=1:len%going through the group components
		comp=coord.coord_groups{k}{l};
		wrap=get(comp,'Wrap');
		if (wrap==0)
		    group_wrap(k)=0;
		end%if
	end%for
end%for

%coord.group_wrap holds for each group 0 if there is at least one
%component that is wrapped
coord.group_wrap=group_wrap;

for k=1:coord.num_coord_groups
	len=length(coord.coord_groups{k});
	comp=coord.coord_groups{k}{1};
	num=get(comp,'Fixed_num_data');
	group_num_trials(k)=num;
	if len==1
        continue;
	else
	for l=2:len
		comp=coord.coord_groups{k}{l};
		in_metod=get(comp,'Input_method');
		if ((isa(comp,'Trial_dur_comp')) && strcmp(in_metod,'STATIC_VALUE'))
            continue;
		end
		num=get(comp,'Fixed_num_data');    
		if ~(num==group_num_trials(k)) 
			valid_group(k)=0;
			crid=get(comp,'Coord_index');
			group_error{k}=['Unequal number of trials for coordinated group : '  num2str(crid)];
			group_num_trials(k)=0;
			break;
		end
	end%for
	end%if
end%for

%valid_group  holds for each group indication if it's a 
%valid group (if the fix_num_trial is equal in all)
coord.valid_group=valid_group;
coord.group_error=group_error;
coord.group_num_trials=group_num_trials;
 
 %%%%% calculating total trials %%%%%%%%
tmp=find(coord.valid_group==0);
if isempty(tmp)
	coord.valid=1;
	trials=1;
	for k=1:coord.num_coord_groups
        trials=coord.group_num_trials(k)*trials;
	end%for
	coord.total_trials=trials;
else
	coord.valid=0;
	coord.total_trials=0;
end%if


trials=1;
if coord.valid
    if any(coord.group_wrap==0) % if there any group that has an unwrapped component
        for k=1:coord.num_coord_groups
            if (coord.group_wrap(k)==0)
                    trials=coord.group_num_trials(k)*trials;
                 elseif coord.group_wrap(k)==1
                    continue;
             end%if
         end%for
	coord.total_trials=trials;
     end
else %~coord.valid
    % if there any group that has a wrapped component then mabey the wrap
    % makes the group valid
    if any(coord.group_wrap==0)
	coord.valid=1;
	for k=1:coord.num_coord_groups
		err_flag=0;
		counter=1;
		len=length(coord.coord_groups{k});
       for l=1:len
			comp=coord.coord_groups{k}{l};
			if (get(comp,'Wrap')==0)
                     if counter==1
						num_data=get(comp,'Fixed_num_data');
						counter=counter+1;
                        trials=trials*num_data;
                     end
			          if ~(get(comp,'Fixed_num_data')==num_data)%more then one unwrap in an invalid group
                          crid=get(comp,'Coord_index');
                           coord.group_error{k}=['More than one unwrap in group: ' num2str(crid) ' with different num of trials!' ];
                           coord.valid=0;
                           err_flag=1;
                           break;
                      end
              end%if  get(comp,'Wrap')==0
          end%for l=1:len
          if err_flag==0
              coord.group_error{k}='';
              if counter==1%all components of this group are wrapped
                  num_data=1;
              end
              coord.group_num_trials(k)=num_data;
              coord.valid_group(k)=1;
          end    
    end%for k=1:coord.num_coord_groups
       coord.total_trials=coord.valid*trials;
   end%if
end%if
coord=class(coord,'Coordinator');
	
