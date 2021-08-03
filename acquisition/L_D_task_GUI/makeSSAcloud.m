function str=makeSSAcloud(s,d,p,nseq)

if nargin<3 || isempty(p),
p(1)=0.1;
p(2)=1-p(1);
end

if nargin<4,
    nseq=10;
end

fname=ls('c:\maestro_results\soundFiles\clouds\');

ind=strmatch('cloud',fname);
clear i t

i=strfind(fname(ind(1),:),'_');
base=fname(ind(1),1:i(end));
clss=strcat(base,num2str(s));
clds=strcat(base,num2str(d));

str=[repmat(strcat('clouds/',clds,'.wav',','),[1 p(1)*nseq]) repmat(strcat('clouds/',clss,'.wav',','),[1 p(2)*nseq])];
str=str(1:end-1);

