function playing = soundIsPlaying(app)

data='soundIsPlaying';
send(app.Qout,data);
gotMsg=false;

while ~gotMsg
    [n, gotMsg]=poll(app.Queue);
end

if n==1
    playing = 1;
elseif n == 0
    playing = 0;
else
    playing = -1;
end