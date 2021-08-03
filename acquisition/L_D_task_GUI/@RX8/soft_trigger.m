function [succeeded,err]=soft_trigger(rx8,num_trig)
dev_num=get(rx8,'Device_num');

err='';
actx_cntrl=get(rx8,'Controler');
if (invoke(actx_cntrl,'SoftTrg',num_trig)==0)
    err_msg = invoke(actx_cntrl,'GetError');
   if length(err_msg) > 0
        err=err_msg;
   succeeded=0;
   end
    str=['%Error Soft-Triggering RX8_',num2str(dev_num)];
else 
    succeeded=1;
    str=['%RX8_',num2str(dev_num),' was soft triggered'];
end

% global Out_Manager;
% if ~isempty(Out_Manager)
%     fid=get(Out_Manager,'Fid');
%     if ~(fid==-1)        
%         fprintf(fid,'\n');
%         fprintf(fid,'%s',str);
%         fprintf(fid,'\n');
%     end
% end