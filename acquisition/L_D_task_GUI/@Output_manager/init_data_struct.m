function out=init_data_struct(out)
out.collected_trial=0;
out.location_in_data=0;
s=size(out.sum_data{1});
for k=1:out.num_elec
out.data{k}=zeros(2,s(2));
out.sum_data{k}=zeros(1,s(2));
end
out.data{out.num_elec+1}=zeros(2,out.num_elec,s(2));
out.sum_data{out.num_elec+1}=zeros(out.num_elec,s(2));
out.trial_data=cell(out.total_trials,out.num_elec);
out.trial_data_npts=zeros(1,out.total_trials);