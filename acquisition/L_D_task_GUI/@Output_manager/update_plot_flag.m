function out_manager = update_plot_flag(out_manager,index,status)
% function out_manager = update_plot_flag(out_manager,index,status,h)
flag_list=get(out_manager,'Plot_flags');
flag_list(index)=status;
% handles_list=get(out_manager,'Plot_handles');
% handles_list(index)=h;
% out_manager=set(out_manager,'Plot_flags',flag_list,'Plot_handles',handles_list);
out_manager=set(out_manager,'Plot_flags',flag_list);
