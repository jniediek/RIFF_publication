function [succeeded,err]=halt(rx8)
dev_num=get(rx8,'Device_num');

err='';
actx_cntrl=get(rx8,'Controler');
if (invoke(actx_cntrl,'Halt')==0)
    err_msg = invoke(actx_cntrl,'GetError');
   if length(err_msg) > 0
        err=err_msg;
   end
    succeeded=0;
    str=['%Error Halting RX8_',num2str(dev_num)];
else 
    succeeded=1;
    str=['%RX8_',num2str(dev_num),' Running is finished'];
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
