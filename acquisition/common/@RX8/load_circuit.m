function er=load_circuit(rx8)

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

e_load=invoke(actx_cntrl,'LoadCOF','RX8_circuit_RIFF.rcx');% Loads circuit'
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
