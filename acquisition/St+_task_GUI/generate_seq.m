a = [1;2;3;0];
b = [1;3;2;0];
r = rand(1,300) < 0.10;

ff = find(r);
ii = find(diff(ff)==1);
fii = ff(ii);
r(fii) = 0;


S = zeros(4,length(r));
S(:,r==1) = repmat(b,1,sum(r==1)),;
S(:,r==0) = repmat(a,1,sum(r==0));

min(diff(find(r)))
imagesc(S)

F1=[0,1047,1319,1568];
S1=F1(S+1);
S1=S1(:)';
S2=S1.*2;
S3=S1.*3;
S4=S1.*4;
