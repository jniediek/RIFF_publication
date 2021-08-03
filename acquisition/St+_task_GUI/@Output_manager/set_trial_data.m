function out=set_trial_data(out,data,trial_index)
for electrode=1:out.num_elec
    % for electrode=1:2
    if out.LFPmask(electrode)
        chan_data=data{electrode};
        len=length(chan_data);
        if len>0
%             tmp=zeros(1,len);
%             tmp(1:len)=chan_data;
            out.trial_data{trial_index,electrode}=chan_data(1:len);
            out.trial_data_npts(trial_index)=len;
        end
%     else
%         out.trial_data{trial_index,electrode}=sparse(size(tmp,1),size(tmp,2));
%         out.trial_data_npts(trial_index)=len;
    end
end
if length(data)>out.num_elec
%     len=size(data{out.num_elec+1},2);
%     tmp=zeros(size(data{out.num_elec+1},1),len);
%     tmp(:,1:len)=data{out.num_elec+1};
    out.trial_data{trial_index,out.num_elec+1}=sparse(data{out.num_elec+1});
end
%
totalbytes=0;
for ii=1:trial_index
    for kk=1:out.num_elec+1
        totalbytes=totalbytes+numel(out.trial_data{ii,kk})*8;
    end
end
disp(['size of trial_data: ' num2str(totalbytes/1e6)]);
