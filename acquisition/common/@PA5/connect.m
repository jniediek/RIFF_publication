function [succeeded,err]=connect(pa5,interface)
global Out_Manager;
dev_num=get(pa5,'Device_num');

err='';
actx_cntrl=get(pa5,'Controler');
dev_num=get(pa5,'Device_num');
% if (invoke(actx_cntrl,'ConnectPA5',interface,dev_num)==0)

if (actx_cntrl.ConnectPA5(interface,dev_num)==0)
    err_msg = invoke(actx_cntrl,'GetError');
   if length(err_msg) > 0
        err=err_msg;
   end
    succeeded=0;
    str=['%Error connecting to PA5_',num2str(dev_num)];
else 
    succeeded=1;
    str=['%PA5_',num2str(dev_num),'''s Connection  established'];
    disp(str);
end

if ~isempty(Out_Manager)
    fid=get(Out_Manager,'Fid');
    if ~(fid==-1)        
        fprintf(fid,'\n');
        fprintf(fid,'%s',str);
        fprintf(fid,'\n');
    end
end
