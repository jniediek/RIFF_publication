function [res_pa5,succeeded,err]=reset(pa5)
dev_num=get(pa5,'Device_num');
err='';
actx_cntrl=get(pa5,'Controler');
dev_num=get(pa5,'Device_num');
res_pa5=NaN;
% if (invoke(actx_cntrl,'ConnectPA5','GB',dev_num)==0)
% if (actx_cntrl.ConnectPA5('GB',dev_num)==0)
%     err_msg = invoke(actx_cntrl,'GetError');
%    if length(err_msg) > 0
%         err=err_msg;
%    end
%     succeeded=0;
%     str=['%Error resetting PA5_',num2str(dev_num)];
%     return;
% end
% if (invoke(actx_cntrl,'Reset')==0)
if (actx_cntrl.Reset==0)
    err_msg = invoke(actx_cntrl,'GetError');
   if length(err_msg) > 0
        err=err_msg;
   end
    succeeded=0;
    str=['%Error resetting PA5_',num2str(dev_num)];
else
    invoke(actx_cntrl,'Display','   0.0dB',0);
    succeeded=1;
    str=['%PA5_',num2str(dev_num),'''s Reset succeeded'];
    disp(str);
end

res_pa5=set(pa5,'Atten',0);

global Out_Manager;
if ~isempty(Out_Manager)
    fid=get(Out_Manager,'Fid');
    if ~(fid==-1)        
        fprintf(fid,'\n');
        fprintf(fid,'%s',str);
        fprintf(fid,'\n');
    end
end
