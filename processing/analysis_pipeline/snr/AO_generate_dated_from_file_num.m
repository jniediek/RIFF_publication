function dated_num = AO_generate_dated_from_file_num(year, month, day, num)
% JN 2020-05-15
% create a dated SNR file number (used to capture some SNR reboot cases)

dated_num = str2double(sprintf('%04d%02d%02d%04d', year, month, day, num));
