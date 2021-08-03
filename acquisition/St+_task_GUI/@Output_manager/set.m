function out = set(out,varargin)
% SET Set Output_manager properties and return the updated object
% Property names are:
% Plot_falgs, Plot_handles.

property_argin = varargin;
while length(property_argin) >= 2,
    prop = property_argin{1};
    if ~isa(prop,'char')
        treat_error(['The property input is not a valid Output_manager property'])
    end
    val = property_argin{2};
    property_argin = property_argin(3:end);
    switch prop
        case 'Collected_trial'
            out.collected_trial=val;
            out.location_in_data=out.location_in_data+1;
            if out.location_in_data>out.total_trials
                out.location_in_data=1;
            end
        case 'Plot_handles'
            out.plot_handles=val;
        case 'Plot_instances'
            out.plot_instances=val;
        case 'Metablock'%for Maestro1 use
            out.meta=val;
            out.collected_trial=0;
            out.location_in_data=0;
            out.trial_dur=[0 0];
            out.trial_npts=[0 0];
            %            s_data=out.sum_data
            s=size(out.sum_data{1});
            for k=1:out.num_elec
                out.data{k}=zeros(2,s(2));
                out.sum_data{k}=zeros(1,s(2));
            end
            out.data{out.num_elec+1}=zeros(2,out.num_elec,s(2));
            out.sum_data{out.num_elec+1}=zeros(out.num_elec,s(2));
            out.total_trials=get(val,'Num_of_trials');
            out.trial_data=cell(out.total_trials,out.num_elec);
            out.trial_data_npts=zeros(1,out.total_trials);
            out.run_line_order=zeros(1,out.total_trials);%the order in which the lines ran
            out.trial_num_in_line=zeros(1,out.total_trials);
        case 'StimList' %for pre-created stimulus table
            out.stimlist=val;
            out.collected_trial=0;
            out.location_in_data=0;
            out.trial_dur=[0 0];
            out.trial_npts=[0 0];
            %            s_data=out.sum_data
            s=size(out.sum_data{1});
            for k=1:out.num_elec
                out.data{k}=zeros(2,s(2));
                out.sum_data{k}=zeros(1,s(2));
            end
            out.data{out.num_elec+1}=zeros(2,out.num_elec,s(2));
            out.sum_data{out.num_elec+1}=zeros(out.num_elec,s(2));
            out.total_trials=height(val.T);
            out.trial_data=cell(out.total_trials,out.num_elec);
            out.trial_data_npts=zeros(1,out.total_trials);
            out.run_line_order=zeros(1,out.total_trials);%the order in which the lines ran
            out.trial_num_in_line=zeros(1,out.total_trials);
            
        case 'Line'%for Search use
            out.line=val;
            out.collected_trial=0;
            out.location_in_data=0;
            out.trial_dur=[0 0];
            out.trial_npts=[0 0];
            s=size(out.sum_data{1});
            for k=1:out.num_elec
                out.data{k}=zeros(2,s(2));
                out.sum_data{k}=zeros(1,s(2));
            end
            out.data{out.num_elec+1}=zeros(2,out.num_elec,s(2));
            out.sum_data{out.num_elec+1}=zeros(out.num_elec,s(2));
            out.total_trials=300;%arbitrarly defined
            out.trial_data=cell(out.total_trials,out.num_elec);
            out.trial_data_npts=zeros(1,out.total_trials);

        case  'Total_trials'
            out.total_trials=val;
        case  'Trial_dur'
            out.trial_dur=val;
        case  'Trial_npts'
            out.trial_npts=val;
        case  'Trial_num_in_line'
            out.trial_num_in_line=val;
        case  'Cur_trial_npts'
            remainder = mod(out.location_in_data,2);
            out.trial_npts(remainder+1)=val;
        case  'Cur_trial_data'
            for k=1:out.num_elec
                chan_data=val{k};
                len=length(chan_data);
                if len>out.buf_size
                    len=out.buf_size;
                end
                dbstop if error
                if len>0
                    remainder = mod(out.location_in_data,2);
                    tmp=zeros(1,out.buf_size);
                    tmp(1:len)=chan_data(1:len);
                    sum_of_data=get(out,'Sum_data');
                    out.sum_data{k}=sum_of_data{k}+tmp;
                    out.data{k}(remainder+1,:)=tmp;
                end
            end
            if length(val)>out.num_elec
                chan_data=val{out.num_elec+1};
                len=size(chan_data,2);
                if len>0
                    remainder = mod(out.location_in_data,2);
                    tmp=zeros(out.num_elec,out.buf_size);
                    if len>out.buf_size
                        chan_data=chan_data(:,1:out.buf_size);
                        len=out.buf_size;
                    end

                    if size(chan_data,1)==16,keyboard,end

                    tmp(:,1:len)=chan_data(:,1:len);
                    sum_of_data=get(out,'Sum_data');
                    out.sum_data{out.num_elec+1}=sum_of_data{out.num_elec+1}+tmp;
                    out.data{out.num_elec+1}(remainder+1,:,:)=tmp;
                end
            end
        case  'File'
            out.file=val;
        case  'Fid'
            out.fid=val;
        case 'Run_line_order'
            out.run_line_order=val;
        otherwise
            treat_error([prop,' is not a valid property'])
    end
end