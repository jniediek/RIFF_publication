function val=get(l_coord,prop_name)
% GET Get Line Coordinator property from the specified object
% and return the value. Property names are:
% Coordinator - the coordinator object
% Basic_line - the Basic line this Coordinator handle
% Components - list of the components of the Basic  line this Coordinator handle
% Num_of_comp - number of components of the Basic line this Coordinator handle
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
   val = l_coord.Coordinator;  
    case 'Basic_line'
        val=l_coord.line;
otherwise
     val=get(l_coord.Coordinator,prop_name);
end

else
    treat_error('The property input must be of type char');
end
