function write_trial_data_result(out,file_name)
data=out.trial_data;
num_data=out.trial_data_npts;
save(file_name,'data','num_data');

