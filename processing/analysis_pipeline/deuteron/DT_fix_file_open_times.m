function table_filestarts = DT_fix_file_open_times(table_filestarts, CD)
% JN 2020-04-22

n_res = height(table_filestarts);

table_filestarts.Relevant_CD_ms = zeros(n_res, 1);

% From Deuteron's manuals:
% CD: Clock difference in seconds: Logger clock time minus transceiver clock time

% this implies
% t_logger = t_transceiver + cd;
% t_transceiver = t_logger - cd;


CD.Logger_Time = CD.Transceiver_Time + CD.CD_ms;

for i = 1:height(table_filestarts)
    idx = find(CD.Logger_Time <= table_filestarts.Time_ms_Logger(i), 1, 'last');
    table_filestarts.Relevant_CD_ms(i) = CD.CD_ms(idx);
end

table_filestarts.Time_ms_Transceiver = ...
    table_filestarts.Time_ms_Logger - table_filestarts.Relevant_CD_ms;