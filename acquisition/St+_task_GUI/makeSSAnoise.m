function str=makeAllnoise

fname=ls('c:\maestro_results\soundFiles\');

c=0;
iifile=strmatch('FN',fname);
for ifile=iifile',
    c=c+1;
    i=strfind(fname(ifile,:),'wav');
    
    names{c}=fname(ifile,1:i+2);
    names{c}(i+3)=',';
end

clear i c

str=cell2mat(names);

str=str(1:end-1);