function val = get(s_coord,prop_name)
% GET Get Signal Coordinator property from the specified object
% and return the value. Property names are:
% Coordinator - the coordinator object
% Main_signal - the Main Signal this Coordinator handle
% Name - of the main signal
% Components - list of the components of the Main Signal this Coordinator handle
% Num_of_comp - number of components of the Main Signal this Coordinator handle
% Coord_indices - list of the indices (used for coordination) of all the
% components
% Num_coord_groups - number of groups (all components in a group have the
% same coordination index) 
% Coord_groups - list of lists  of all components in each group
% Valid_group - for each group holds an indication if it's a valid group
% Group_error - for each invalid group holds the relevant error message 
% Group_wrap - indicates if all the group components are wrapped (0 if at least one unwrapped)
% Group_num_trials - holds for each group the calculated number of trials
% Total_trials - holds the total number of trials after the coordination process
%Valid - indicates if the coordination process succeeded

if isa(prop_name,'char')
	switch prop_name
	case 'Coordinator'
       val = s_coord.Coordinator;  
       case 'Main_signal'
       val = s_coord.m_sig;
	case 'Name'
        val=get(s_coord.m_sig,'Name');
	otherwise
          val=get(s_coord.Coordinator,prop_name);
	end
    
    else
    treat_error('The property input must be of type char');
end