function [snr_times, deuteron_tables, expdata] = ...
    prepare_one_session_folder(expdata, i, S)

row = expdata.rat_table(i, :);
out_folder_rat = expdata.folders.out_folder_rat;

fname = sprintf('%02d_%s', row.SessionID, row.SessionType{1});
out_folder_session = fullfile(out_folder_rat, fname);

if ~isfolder(out_folder_session)
    mkdir(out_folder_session)
    log_msg(out_folder_rat, 'create-folder', out_folder_session);
end
init_logfile(out_folder_session);
expdata.folders.session_folders{i} = out_folder_session;

% place the relevant SNR events in the session folder

% JN 2020-05-15 adding support for dated SNR File numbers
if ismember('DatedFromFileNo', S.snr_times.Properties.VariableNames)
    
    if row.SNRFilesStart > 100000
        SNRFilesStartDated = row.SNRFilesStart;
    else
        
        SNRFilesStartDated = AO_generate_dated_from_file_num(row.Year, ...
            row.Month, row.Day, row.SNRFilesStart);
    end
    
    if row.SNRFilesStop > 100000
        SNRFilesStopDated = row.SNRFilesStop;
    else
        SNRFilesStopDated = AO_generate_dated_from_file_num(row.Year, ...
            row.Month, row.Day, row.SNRFilesStop);
    end
    
    SNREventsStart = find(S.snr_times.DatedFromFileNo == ...
        SNRFilesStartDated, 1, 'first');
    
    SNREventsStop = find(S.snr_times.DatedFromFileNo == ...
        SNRFilesStopDated, 1, 'last');
    
else
    
    SNREventsStart = find(S.snr_times.FromFileNo == ...
        row.SNRFilesStart, 1, 'first');
    
    SNREventsStop = find(S.snr_times.FromFileNo == ...
        row.SNRFilesStop, 1, 'last');
end

snr_times = S.snr_times(SNREventsStart:SNREventsStop, :);

% === ADDED BY ANA ON 21/10/19
% fix jump in Snr trigger times during session
snr_times.Time = fix_snr_times(snr_times.Time, out_folder_session);

snr_times.SessionNo(:) = i;

% === ADDED BY ALEX ON 15/08/19
% the cropped SNR times for this specific exp is used in the visualizer
% sparing double parsing
fname = fullfile(out_folder_session, 'snr_times.mat');
save(fname, 'snr_times');
log_msg(out_folder_session, 'save-mat', fname);

% JN 2020-04-24
% save Deuteron TTLs for this specific experiment here
% this is based on the Transceiver Time

if ~expdata.do_deuteron
    deuteron_tables = struct();
    return
end

idx_start = find(S.table_filestarts.File_num >= ...
    row.NeuralFilesStart - 1, 1, 'first');
idx_stop = find(S.table_filestarts.File_num <= ...
    row.NeuralFilesStop - 1, 1, 'last');

table_filestarts = S.table_filestarts(idx_start:idx_stop, :);
table_filestarts.SessionNo(:) = i;

time_start = table_filestarts.Time_ms_Transceiver(1);
time_stop = table_filestarts.Time_ms_Transceiver(end) + 8192;

in_snr_times = snr_times.Time(snr_times.EventType == 'snd');


if expdata.has_autolog
    % JN 2020-04-24 here we can use the SrcFileIdx
    % the slow find syntax is used here to make changes easier in
    % the future
    log_msg(out_folder_session, 'autolog-info', ...
        'starting Deuteron autolog processing')
    S.TTL_autolog = sortrows(S.TTL_autolog, 'Transceiver_Time');
    idx_start = find(S.TTL_autolog.Transceiver_Time >= ...
        time_start, 1, 'first');
    idx_stop = find(S.TTL_autolog.Transceiver_Time <= ...
        time_stop, 1, 'last');
    
    table_ttls_autolog = S.TTL_autolog(idx_start:idx_stop, :);
    table_ttls_autolog = table_ttls_autolog(table_ttls_autolog.Logger_SN == row.LoggerSN,:); %AP 211020 - better filter on the data
    n_src_files = numel(unique(table_ttls_autolog.Src_File_Idx));
    log_msg(out_folder_session, 'autolog-info', ...
        sprintf('autolog has %d source files', n_src_files));
    % in a correct experiment, there should be only 1 autolog source file
    % involved
    
    % connect the TTLs and the SNR times
    in_ttl_times = ...
        table_ttls_autolog.Transceiver_Time(table_ttls_autolog.State == 1);
    out_times = DT_add_snr_times_to_ttl_times(in_ttl_times, ...
        in_snr_times, out_folder_session);
    table_ttls_autolog.snr_times(:) = -1;
    table_ttls_autolog.snr_times(table_ttls_autolog.State == 1) = out_times;
    table_ttls_autolog.SessionNo(:) = i;
    fname = fullfile(out_folder_session, 'table_ttls_autolog.mat');
    save(fname, 'table_ttls_autolog');
    log_msg(out_folder_session, 'save-mat', fname);
    deuteron_tables.table_ttls_autolog = table_ttls_autolog;
end

if expdata.has_table_ttls
    log_msg(out_folder_session, 'ttl-info', ...
        'starting Deuteron logger TTL processing');
    time_start = table_filestarts.Time_ms_Transceiver(1);
    time_stop = table_filestarts.Time_ms_Transceiver(end) + 8192;
    
    idx_start = find(S.TTL_logger.Time_ms >= time_start, 1, 'first');
    idx_stop = find(S.TTL_logger.Time_ms <= time_stop, 1, 'last');
    
    table_ttls = S.TTL_logger(idx_start:idx_stop, :);
    in_ttl_times = table_ttls.Time_ms(table_ttls.Direction == "rising");
    out_times = DT_add_snr_times_to_ttl_times(in_ttl_times, ...
            in_snr_times, out_folder_session);
    
    table_ttls.snr_times(:) = -1;
    table_ttls.SessionNo(:) = i;
        
    if isempty(out_times)
        log_msg(out_folder_session, 'ttl-info', ...
            'unable to align Deuteron logger TTLs with SnR times, check for lost TTLs');
    else
        log_msg(out_folder_session, 'ttl-info', ...
            'successfully aligned Deuteorn logger TTLs with SnR times');
        table_ttls.snr_times(table_ttls.Direction == "rising") = out_times;
    end
    
    fname = fullfile(out_folder_session, 'table_ttls.mat');
    save(fname, 'table_ttls');
    log_msg(out_folder_session, 'save-mat', fname);
    deuteron_tables.table_ttls = table_ttls;
end


% at this point add SNR based timestamps to filestarts
if expdata.has_autolog
    idx = table_ttls_autolog.State == 1;
    ct_tr = table_ttls_autolog.Transceiver_Time(idx);
    ct_snr = table_ttls_autolog.snr_times(idx);
elseif expdata.has_table_ttls
    idx = table_ttls.Direction == "rising";
    ct_tr = table_ttls.Time_ms(idx);
    ct_snr = table_ttls.snr_times(idx);
end

% for each file start time, find the neighboring TTLs, and use their
% times to convert the file start time to SnR times
table_filestarts.snr_times(:) = -1;
comp_t = table_filestarts.Time_ms_Transceiver;

for i_filestart = 1:height(table_filestarts)
    
    before = find(ct_tr <= comp_t(i_filestart), 1, 'last');
    after = find(ct_tr >= comp_t(i_filestart), 1, 'first');
    
    if isempty(before)
        before = after;
        after = find(ct_tr > ct_tr(before), 1, 'first');
    end
    
    if isempty(after)
        after = before;
        before = find(ct_tr < ct_tr(after), 1, 'last');
    end
        
    snr_neigh = ct_snr([before after]);
    tr_neigh = ct_tr([before after]);
    
    % linear inter/extrapolation
    out = diff(snr_neigh)/diff(tr_neigh) * ...
        (comp_t(i_filestart) - tr_neigh(1)) + ...
        snr_neigh(1);

    table_filestarts.snr_times(i_filestart) = out;
    if isnan(out)
        keyboard
    end
end

deuteron_tables.table_filestarts = table_filestarts;

fname = fullfile(out_folder_session, 'table_filestarts.mat');
save(fname, 'table_filestarts');
log_msg(out_folder_session, 'save-mat', fname);


function fixed_times = fix_snr_times(snr_times, data_folder)
% JN 2020-04-24: This function is by Ana P

fixed_times = snr_times;

jump_point = find(diff(snr_times) < mean(diff(snr_times))/10);

if length(jump_point) == 1
    fixed_times(jump_point+1:end) = ...
        fixed_times(jump_point+1:end) + fixed_times(jump_point);
    log_msg(data_folder, 'fix-snr-times', ...
        sprintf('Fixed jump in SNR timestamps at index %d', jump_point)) %AP 240520 syntax fix
end

