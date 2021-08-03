function analyse_stack_sizes()

    % === Get the file name ====
    
    base_dir = 'C:\logging_data\';
    [filename, pathname] = uigetfile({'*.txt'}, 'Select Movie(or few...)', base_dir);
    if isequal(filename,0) || isequal(pathname,0)
         disp('User pressed cancel')
    else
         disp(['User selected ', fullfile(pathname, filename)])
    end
    
    % ==== Read the file into a table ====
    
    h_wb = waitbar(0.3, 'Parsing the file...');
    data = readmatrix(fullfile(pathname, filename), 'NumHeaderLines', 1);
    delete(h_wb);
    
    % === Plot the results ====
    
    figure;
    plot(data(:, 4), '.');
    xlabel('Samples');
    ylabel('Stack size');
    samp_n = length(data);
    rec_t_min = samp_n / 30 / 60;
    title(['No. frames: ' num2str(length(data)) ' | Time(min): ' num2str(rec_t_min) ...
           ' | Hours: ' num2str(rec_t_min/60)]);
    ylim([0 max(data(:, 4)) + 3]);
end