
 Interface='GB';
  actx_cntrl=get(rx8,'Controler');
 dev_num=get(rx8,'Device_num');

% RP=actxcontrol('RPco.x',[5 5 26 26]);  

if invoke(actx_cntrl,'ConnectRX8',Interface,dev_num); %connects RP2 through GIGABIT interface

%   if RP.ConnectRX8('GB',1) 
      disp 'connected' 
  else 
       disp 'Unable to connect' 
end 

er='';

% if dev_num==1
%     Circuit_Path='Z:\tdt\rpvds\signal_data1_spikes.rcx';
% elseif dev_num==2
%     Circuit_Path='Z:\tdt\rpvds\signal_data2_spikes.rcx';
% end
% e_clear=RP. ClearCOF;
e_clear=invoke(actx_cntrl,'ClearCOF') ;%Clears all the Buffers and circuits on that RP2

 if e_clear==0 
    disp ' The circuit is not clear' 
  else 
    disp 'Circuit is clear' 
  end

% e_load=RP.LoadCOF('Z:\signal_data1.rcx'); % Loads circuit 
e_load=invoke(actx_cntrl,'LoadCOF','Z:\mix_try.rcx');% Loads circuit'  
if e_load==0 
    disp 'Error loading circuit' 
  else 
    disp 'Circuit ready to run' 
end

% invoke(RP,'Run'); %Starts Circuit'
% %%Status=RP.GetStatus;
 Status=double(invoke(actx_cntrl,'GetStatus'));%converts value to bin'
if bitget(Status,1)==0;%checks for errors in starting circuit'
   er=['Error connecting to RX8_',num2str(dev_num)];
elseif bitget(Status,2)==0; %checks for connection'
   er=['Error loading circuit to RX8_',num2str(dev_num)];
end

if (invoke(actx_cntrl,'Run')==0)
    err_msg = invoke(actx_cntrl,'GetError');
   if length(err_msg) > 0
        err=err_msg;
   end
    succeeded=0;
    str=['%Error Running RX8_',num2str(dev_num)];
else 
    succeeded=1;
    str=['%RX8_',num2str(dev_num),' is Running'];
end

global Out_Manager;
if ~isempty(Out_Manager)
    fid=get(Out_Manager,'Fid');
    if ~(fid==-1)        
        fprintf(fid,'\n');
        fprintf(fid,'%s',str);
        fprintf(fid,'\n');
    end
end

% 
% [check_run,run_err]=run(actx_cntrl);%Starts rp2_1 Circuit'
% if ~check_run
%     errordlg('Error running circuit of RP2_1','TDT Error','replace');
%     handles=end_exp(actx_cntrl);
%     return;
% end
% [check_run,run_err]=run(handles.RPX2);%Starts rp2_2 Circuit'
% if ~check_run
%     errordlg('Error running circuit of RP2_2','TDT Error','replace');
%     handles=end_exp(handles);
%     return;
% end
% 
% if (invoke(actx_cntrl,'SoftTrg',2)==0)
%     err_msg = invoke(actx_cntrl,'GetError');
%    if length(err_msg) > 0
%         err=err_msg;
%    succeeded=0;
%    end
%     str=['%Error Soft-Triggering RX8_',num2str(dev_num)];
% else 
%     succeeded=1;
%     str=['%RX8_',num2str(dev_num),' was soft triggered'];
% end
% % 
% global Out_Manager;
% if ~isempty(Out_Manager)
%     fid=get(Out_Manager,'Fid');
%     if ~(fid==-1)        
%         fprintf(fid,'\n');
%         fprintf(fid,'%s',str);
%         fprintf(fid,'\n');
%     end
% end

% set_tag_val(fig.actx_cntrl,'trial_dur',cur_trial_dur)
succeeded=1;
check=invoke(actx_cntrl,'SetTagVal','r_connect',r_connect);
if ~check
    succeeded=0;
    global Out_Manager;
    if ~isempty(Out_Manager)
        fid=get(Out_Manager,'Fid');
        dev_num=get(rx8,'Device_num');
        if ~(fid==-1)
            str=['%Error reading data from  RX8_',num2str(dev_num)];
            fprintf(fid,'\n');
            fprintf(fid,'%s',str);
            fprintf(fid,'\n');
        end
    end
end   


succeeded=1;
check=invoke(actx_cntrl,'SetTagVal','l_connect',1);
if ~check
    succeeded=0;
    global Out_Manager;
    if ~isempty(Out_Manager)
        fid=get(Out_Manager,'Fid');
        dev_num=get(rx8,'Device_num');
        if ~(fid==-1)
            str=['%Error reading data from  RX8_',num2str(dev_num)];
            fprintf(fid,'\n');
            fprintf(fid,'%s',str);
            fprintf(fid,'\n');
        end
    end
end   

