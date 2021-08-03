function out_manager = update_plot_handle(out_manager,index,h)
handles_list=get(out_manager,'Plot_handles');
handles_list(index)=h;
out_manager=set(out_manager,'Plot_handles',handles_list);
