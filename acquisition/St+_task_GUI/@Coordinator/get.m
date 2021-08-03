function val = get(coord,prop_name)
% GET Get Coordinator property from the specified object
% and return the value. Property names are:
% Components - list of the components of the object this Coordinator handle
% Num_of_comp - number of components of the object this Coordinator handle
% Old_ooord_indices - the original list of the indices (before processing
% it to a succesive sequence of numbers from 1 to the number of groups.
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
     case 'Components'
        val = coord.components;  
      case 'Num_of_comp'
        val = coord.num_of_comp;   
	case 'Coord_indices'
        val = coord.coord_indices;
     case 'Old_coord_indices'
        val = coord.old_coord_indices;
	case 'Num_coord_groups'
        val = coord.num_coord_groups;
	case 'Coord_groups'
        val = coord.coord_groups;
	case 'Valid_group'
        val = coord.valid_group;  
	case 'Group_error'
        val = coord.group_error; 
     case 'Group_wrap'
        val = coord.group_wrap; 
	case 'Group_num_trials'
        val = coord.group_num_trials;
      case 'Total_trials'
        val = coord.total_trials;
        case 'Valid'
        val = coord.valid;
      otherwise
        treat_error([prop_name,' is not a valid Coordinator property']);
	end

else
    treat_error('The property input must be of type char');
end


			
		