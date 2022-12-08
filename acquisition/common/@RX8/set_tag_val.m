function succeeded=set_tag_val(rx8,tag_name,val)
succeeded=1;
actx_cntrl=get(rx8,'Controler');
check=invoke(actx_cntrl,'SetTagVal',tag_name,val);
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