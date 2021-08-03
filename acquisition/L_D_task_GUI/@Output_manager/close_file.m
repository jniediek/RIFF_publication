function out=close_file(out,file_name)
if ~(out.fid==-1)
    fclose(out.fid);
end
out.fid=-1;