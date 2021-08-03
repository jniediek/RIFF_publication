function  out = Output_manager(varargin)
%   OUTPUT_MANAGER class constructor.
%   OUTPUT_MANAGER constructs an Output_manager with a given name.


global NUM_PLOT_TYPES;
global num_elec
NUM_PLOT_TYPES=6;

switch nargin
case 0
		% if no input arguments, create a default object
        size_of_buffer=4000;
        out.num_elec=num_elec;
        % WOrk around to save online only some of the LFP channels:
        % ELN 201016
        out.LFPmask=zeros(1,num_elec);
        out.LFPmask(1:4:end)=1;
        % End workaround
        disp(['Default number of channels := ' num2str(out.num_elec)])
        out.collected_trial=0;
        out.location_in_data=0;
        %holds for each type of plot the list of handles of all instances
        %of the plot
		out.plot_handles=cell(1,NUM_PLOT_TYPES);
         %holds for each type of plot the number of instances of it
        out.plot_instances=zeros(1,NUM_PLOT_TYPES);
        out.trial_dur=[0 0];
        out.trial_npts=[0 0];
        out.trial_num_in_line=[];
    %one for each channel
        for k=1:out.num_elec%holds the data of the last 2 trial
            out.data{k}=zeros(2,size_of_buffer);
            out.sum_data{k}=zeros(1,size_of_buffer);
        end
        out.data{out.num_elec+1}=zeros(out.num_elec,size_of_buffer,2);
        out.sum_data{out.num_elec+1}=zeros(out.num_elec,size_of_buffer);
        out.trial_data={};
        out.trial_data_npts=[];
        out.run_line_order=[];
        out.total_trials=0;
        out.stimlist=[];
        out.meta={};
        out.line={};
        out.file={};
        out.fid=-1;
        out.buf_rate=round(48828.125/50);
        out.buf_size=4000;
		out=class(out,'Output_manager');

case 1
        if (isa(varargin{1},'Output_manager'))
             out = varargin{1}; 
         else
            treat_error('Input argument is not an Output_manager object');
        end

    case 3
        out.collected_trial=0;
        out.location_in_data=0;
        out.num_elec=varargin{3};
        % WOrk around to save online only some of the LFP channels:
        % ELN 201016
        out.LFPmask=zeros(1,out.num_elec);
        out.LFPmask(1:4:end)=1;
        % End workaround
        %holds for each type of plot the list of handles of all instances
        %of the plot
		out.plot_handles=cell(1,NUM_PLOT_TYPES);
        %holds for each type of plot the number of instances of it
        out.plot_instances=zeros(1,NUM_PLOT_TYPES);
        out.trial_dur=[0 0];
        out.trial_npts=[0 0];
        out.trial_num_in_line=[];
        %one for each channel
        size_of_buffer=varargin{2};
        for k=1:out.num_elec,
            out.data{k}=zeros(2,size_of_buffer);
            out.sum_data{k}=zeros(1,size_of_buffer);
        end
        out.data{out.num_elec+1}=zeros(2,out.num_elec,size_of_buffer);
        out.sum_data{out.num_elec+1}=zeros(out.num_elec,size_of_buffer);
        out.run_line_order=[];
        out.stimlist=[];
        out.meta={};
        out.line={};
        out.total_trials=0;
        out.trial_data={};
        out.trial_data_npts=[];
        out.file={};
        out.fid=-1;
        out.buf_rate=varargin{1};
        out.buf_size=varargin{2};
        out=class(out,'Output_manager');

    otherwise
        treat_error('Wrong input argument to Output_manager');
end
