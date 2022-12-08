function [result_pa5,succeeded,err]=set_atten(pa5,atten)
err='';
actx_cntrl=get(pa5,'Controler');
dev_num=get(pa5,'Device_num');
cur_atten=get(pa5,'Atten');
if atten==cur_atten
        %     if ~(atten==get_atten_display(pa5))
         %       invoke(actx_cntrl,'Display',['Att=',num2str(atten),'dB   '],0);
        %     end
    succeeded=1;
    result_pa5=pa5;
    return;
end

if (invoke(actx_cntrl,'SetAtten',atten)==0)
    err_msg = invoke(actx_cntrl,'GetError');
   if length(err_msg) > 0
        err=err_msg;
   end
   invoke(actx_cntrl,'Display',err,0);
    succeeded=0;
    str=['%Error while setting Attenuation  level of ',num2str(atten),' to PA5_',num2str(dev_num)];
    result_pa5=pa5;
else 
%    invoke(actx_cntrl,'Display',['Att=',num2str(atten),'dB'     ],  0);
    succeeded=1;
    str=['%Attenuation level of ',num2str(atten),' was set correctly to PA5_',num2str(dev_num)];
    result_pa5=set(pa5,'Atten',atten);
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