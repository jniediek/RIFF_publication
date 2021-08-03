function robot_calibration(soundOn)
global vars
    
    delete(instrfind);
    delete(timerfindall);
    if(nargin < 1)
        vars.soundOn = false;
    else
        vars.soundOn = soundOn;
    end
    if(soundOn)
        vars.tcp = tcpip('132.64.61.88', 80, 'NetworkRole', 'client');
        try
            fopen(vars.tcp);
            disp('Link to Maestro is up!');
        catch
            disp('=====    Handshake with Maestro failed!    =====');
            return;
        end
    end
    %============ Dense block check ================
%     rot_long = 0.25;
%     rot_step = 0.15;
%     line = 0.2;
%     vars.movement_time = [
%                           rot_long rot_step rot_step rot_step rot_step  rot_long line...
%                           rot_long rot_step rot_step rot_step rot_step  rot_long line];
%     vars.iters = length(vars.movement_time);
%     vars.move = ['d' 'a' 'a' 'a' 'a' 'd' 's'...
%                  'd' 'a' 'a' 'a' 'a' 'd' 's'];
    
    %============ Dense block check ================

    line = 1;
    vars.movement_time = [line line line line line line line line line line];
    vars.move = ['s' 's' 's' 's' 's' 's' 's' 's' 's' 's'];
    
%     turn = 0.7;
%     line = 0.65;
%     vars.movement_time = [turn line turn (line-0.4)];
%     vars.move = ['d' 's' 'a' 'w'];
%     
    vars.iters = length(vars.movement_time);
    %============ connection to robot =================
    
    vars.robot_elivating = strcmp(vars.move, 'r') || strcmp(vars.move, 'f');
    try
        try
            robot_h = serial('COM3', 'BaudRate', 19200);
            robot_h.InputBufferSize = 1000000;
            fopen(robot_h);
            disp('COM3');
        catch
            robot_h = serial('COM4', 'BaudRate', 19200);
            robot_h.InputBufferSize = 1000000;
            fopen(robot_h);
            disp('COM4');
        end
        
        disp('=== Robot mounted ===');
    catch
        disp('=== COM FAILURE ===');
        return;
    end
    pause(2);   %% boot time of the arduino
    vars.i = 0;
    vars.robot_h = robot_h;
    vars.timer_start = timer('ExecutionMode', 'singleShot', 'StartDelay', 15, 'TimerFcn', {@start_movement});
    if(~vars.soundOn)
        set(vars.timer_start, 'StartDelay', 1);
    end
    vars.timer_end = timer('ExecutionMode', 'singleShot', 'StartDelay', vars.movement_time(1), 'TimerFcn', {@stop_movement});

    %=============== calibration loop ==================
    disp('=== Robot calib. seq. started! ===');
    pause(3); % Pause for the operator to reach the RIFF
%     start_movement(1, 1);
    stop_movement(1, 1);
end


 %=============== Timer callback ==================

function start_movement(~, ~)
    global vars
    if(vars.robot_elivating)
        fwrite(vars.robot_h, 'e');
    end
    disp(['performing move ' num2str(vars.i + 1)]);
    if(length(vars.move) > 1)
        if(length(vars.move) == length(vars.movement_time))
            set(vars.timer_end, 'StartDelay', vars.movement_time(vars.i+1))
            tic;
            fwrite(vars.robot_h, vars.move(vars.i+1));
        else
            tic;
            fwrite(vars.robot_h, vars.move(vars.i+1));
        end
    else
        fwrite(vars.robot_h, vars.move);
        tic;
    end
    start(vars.timer_end);
end

function stop_movement(~, ~)
    global vars
    fwrite(vars.robot_h, 'x');
    toc
    pause(0.5); % movement decays
    if(vars.robot_elivating)
        fwrite(vars.robot_h, 'e');   % stop data transmition from robot
        pause(0.1); % verify that all data was transmitted
        try
            data = fread(vars.robot_h, vars.robot_h.BytesAvailable);
        catch
            data = [];
        end
        turns = sum(diff(data(1:2:end)) > 0.5);
        disp(['turns: ' num2str(turns) ':' num2str(turns/60/3, 3)]);
    end
    vars.i = vars.i + 1;
    
    if(vars.i < vars.iters)
        if(vars.soundOn)
            fwrite(vars.tcp, [1 1 1], 'short');
        end
        start(vars.timer_start);
    else
        disp(' ======= Movement loop ended ================= ');
        fclose(vars.robot_h);
        
        if(vars.soundOn)
            fwrite(vars.tcp, [-7 -7 -7], 'short');
        end
        fclose(instrfind);
    end
%     figure; plot(data);
end