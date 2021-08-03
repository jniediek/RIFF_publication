function RIFF_audio_calibration()
    global vars
    vars.elivation_tick = 0;
    vars.circ_tick = 0;
    vars.line_tick = 0;
    vars.goesUp = 1;
    vars.z_res = 1;
    vars.x_res = 1;
    vars.doTurn = 1;
    delete(timerfindall);
    vars.timer_h1 = timer('ExecutionMode', 'singleShot',...
                          'StartDelay', 0.01, 'TimerFcn', {@main_loop});
    vars.timer_h2 = timer('ExecutionMode', 'singleShot',...
                          'StartDelay', 0.01, 'TimerFcn', {@main_loop});
    vars.tcp = tcpip('localhost',80,'NetworkRole','client');
    fopen(vars.tcp);
    move_circ('start');
    play_sound();    
end

function move_z()
    global vars
%     disp(['z: ' num2str(vars.elivation_tick)]);
    if(vars.goesUp)
        %%% move up;
    else
         %%% move down;
    end
end

function move_line()
    global vars
    %%% moves up or down
%     disp(['line: ' num2str(vars.line_tick)]);
end

function move_circ(op)
    global vars
    %%% moves up or down
    switch op
        case 'start'
%             disp(['circ: start']);
            %%% move right 90 deg
        case 'step'
%             disp(['circ: ' num2str(vars.circ_tick)]);
            %%% move left 180/res deg
        case 'end'
%             disp(['circ: end']);
            %%% move right 90 deg
    end
end

function play_sound()
    global vars
    fwrite(vars.tcp, [vars.elivation_tick vars.circ_tick vars.line_tick], 'short');
    if(strcmp(get(vars.timer_h1, 'running'), 'off'))
        start(vars.timer_h1);
    else
        if(strcmp(get(vars.timer_h2, 'running'), 'on'))
            disp('Both timer busy!!');
            return;
        end
        start(vars.timer_h2);
    end
end

function main_loop(~, ~)
    global vars
    %%% next_z
%     disp(['z:' num2str(vars.elivation_tick) ' circ:' num2str(vars.circ_tick) ' line:' num2str(vars.line_tick)]);
    if(vars.elivation_tick < 11)
        move_z();
        play_sound();
        vars.elivation_tick = vars.elivation_tick + vars.z_res;
        return;
    end
    vars.elivation_tick = 0;
    vars.goesUp = ~vars.goesUp;
    
    %%% next_rot
    if(vars.doTurn)
        vars.circ_tick = vars.circ_tick + vars.x_res;
        if(vars.circ_tick < 5)
            move_circ('step');
            main_loop(1, 1);
            return;
        else
            vars.circ_tick = 0;
            vars.doTurn = 0;
            move_circ('end');
        end
    end
    %%% next_advance
    vars.line_tick = vars.line_tick + vars.x_res;
    if(vars.line_tick < 75)        
        if((vars.line_tick < 5) || ((vars.line_tick >= 35) && (vars.line_tick < 40)) || (vars.line_tick >= 70))
            vars.doTurn = 1;
            vars.x_res = 1;
            vars.z_res = 1;
            move_line();
            move_circ('start');
        else
            vars.x_res = 5;
            vars.z_res = 5;
            move_line();
        end
        main_loop(1,1); %% recursion call, perform the turn and record
    else %%% finish
        fwrite(vars.tcp, [-7 -7 -7], 'short');
        fclose(vars.tcp);
        stop([vars.timer_h2 vars.timer_h1]);
        delete([vars.timer_h2 vars.timer_h1]);
        disp('=============== Calibration sequence has ended! ===============');
    end
end