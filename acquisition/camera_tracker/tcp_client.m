function [] = tcp_client()
    h_maestro = tcpip('132.64.105.163', 81, 'NetworkRole', 'client');
    fopen(h_maestro);
    pause(0.5);
%     t_get = tcpip('132.64.61.62',88,'NetworkRole','server');
%     % Wait for connection
%     t_get.InputBufferSize = 512;
%     disp('Waiting for connection');
%     fopen(t_get);
    disp('Connection OK');
    
    time1 = tic();
    fwrite(h_maestro, typecast(int16([77 88]), 'int32'), 'long');
    while h_maestro.BytesAvailable == 0
        1;
    end
    fread(h_maestro, h_maestro.BytesAvailable/2, 'short')
    toc(time1);
    disp('Finished sending!');
end