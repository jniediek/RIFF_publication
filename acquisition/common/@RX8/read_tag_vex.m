function [data,succeeded]=read_tag_vex(rx8,buf_name,num_samples,Srctype,Dsttype,nchannels,trial_num)
data=[];
dev_num=get(rx8,'Device_num');
succeeded=1;
actx_cntrl=get(rx8,'Controler');
data=invoke(actx_cntrl, 'ReadTagVEX', buf_name, 0,num_samples,Srctype,Dsttype,nchannels);
if (isempty(data))
    succeeded=0;
    str=['%Error reading data from  RX8_',num2str(dev_num)];
else 
    succeeded=1;
    num=num2str(trial_num);
    str=['%RX8_',num2str(dev_num),'  data retrieving succeeded. Number of samples read for trial  ',num,' : ',num2str(num_samples)];
end

% global Out_Manager;
% if ~isempty(Out_Manager)
%     fid=get(Out_Manager,'Fid');
% if ~(fid==-1)        
%     fprintf(fid,'\n');
%     fprintf(fid,'%s',str);
%     fprintf(fid,'\n');
% end
% end
  