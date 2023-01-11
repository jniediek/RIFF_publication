function data = dt2_read_kilosort2(fname, n_channels)
% AK 07/02/2019
% Don't convert to double and don't convert to uV

fid = fopen(fname, 'r');
int_data = fread(fid, 'uint16=>uint16');
fclose(fid);

% Memory math: Typical 'NEUR0000.DT2' file from 31.01.19 is 16MB. Length of recording is 8.19 seconds
% When loaded as 'double' it takes 67MB
% When loaded as 'uint16' it takes 8.4MB
% raw_0_50.mat takes on disk 270MB w/ compressed, 410MB w/o compression

data = (reshape(int_data, n_channels, length(int_data)/n_channels))';