function str=makeAllcloud

fname=ls('c:\maestro_results\soundFiles\clouds500\');
clear names
c=0;
iifile=strmatch('cloud',fname);

iifile=iifile(300:399);
for ifile=iifile',
    disp(num2str(ifile))
    disp(fname(ifile,:))
    c=c+1;
    i=strfind(fname(ifile,:),'wav');
    
    names{c}=['clouds500/' fname(ifile,1:i+2)];
    names{c}(length(names{c})+1)=',';
end

repfile=17;
iifile=repfile*ones(1,50);
i=strfind(fname(ifile,:),'_');
base=['clouds/' fname(ifile,1:i(end))];
for ifile=iifile,
    c=c+1;
    
    names{c}=[base num2str(ifile) '.wav,'];
end

clear i c

str=cell2mat(names);
str=str(1:end-1);
