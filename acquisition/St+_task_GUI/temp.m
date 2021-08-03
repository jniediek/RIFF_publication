vals=linspace(150,450,5);
hvals=ones(1,5)*250/5;
a(1)=50;
for ii=2:250
    shortest=300-a(ii-1);
    list=find(vals>=shortest);
    rr=randi(length(list));
    while hvals(list(rr))==0
        disp(['too many' num2str(vals(list(rr)))]);
        rr=randi(length(list));
    end
    a(ii)=vals(list(rr))-shortest;
    hvals(list(rr))=hvals(list(rr))-1;
end
