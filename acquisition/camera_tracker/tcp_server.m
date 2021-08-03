function [points] = tcp_server()
    h = tcpip('localhost',80,'NetworkRole','server');
    % Wait for connection
    disp('Waiting for connection');
    h.InputBufferSize = 6;
    fopen(h);
    flag = true;
    points = [];
    disp('gone into loop')
    while flag
        if(h.BytesAvailable)
            data = fread(h, h.BytesAvailable/2, 'short');
            points = [points data];
            if(sum(data) == -21)
                fclose(h);
                break;
            end
        end
    end
%     
% 
%     t_send = tcpip('132.64.61.32',88,'NetworkRole','client');
%     fopen(t_send);
%     disp('Connection OK');
    
%     tic;
%     for i = 1:1000
%         fwrite(t_send, [i*2-1,i*2]);
%         DataReceived=fread(t_get, 2);
%     end
%     timing = toc;
%     fwrite(t_send, [0,0]);
%     Read data from the socket
%     disp('Done');
    imagesc(points); title(['Calibration time: ' num2str(length(points)*15/60/60, 2) ' hours']);
    disp('Done');
end