% function err=get_coord_errors(s_coord)
% 
% 	if nargin==1  
%        %coord=s_coord.Coordinator;
%        n=get(s_coord,'Num_coord_groups');
%        group_error=get(s_coord,'Group_error');
%        tmp=group_error{1};
%        if n==1
%            err=tmp;
%        end
%        valid_group=get(s_coord,'Valid_group');
%        for index=2:n
%            if valid_group(index)==0
%          tmp=  strvcat(tmp,group_error{index});
%      end
%      end
%      err=tmp;
% 	else
% 	    treat_error('Wrong number of input arguments for get_coord_errors');
% 	end
%        