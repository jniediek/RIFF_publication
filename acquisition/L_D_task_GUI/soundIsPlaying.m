function playing = soundIsPlaying(app)
% zerarr = zeros(1,length(app.ASIODev.ChannelMapping));
% y=0;
% for ii = 1:3
%     y=y+app.ASIODev(zerarr);
% end
% n=1;
% while n==1
data='soundIsPlaying';
send(app.Qout,data);
gotMsg=false;
while ~gotMsg
    [n, gotMsg]=poll(app.Queue);
end
% end
% playing = n;
if n==1 %y==0
    playing = 1;
elseif n== 0
    playing = 0;
else
    playing = -1;
end