function events = AO_extract_ttls_from_mpx(fname)
% JN 2019-02-10
% extract TTL events from MPX files

fid = fopen(fname, 'r');
data = fread(fid, 'uchar=>uchar');
fclose(fid);

pre_alloc_size = 30000;

isAnalog = zeros(pre_alloc_size, 1);
ttlnums = zeros(pre_alloc_size, 1);
sampling_rates = zeros(pre_alloc_size, 1);

output = zeros(500000, 3);
event_idx = 1;

len = typecast(data(1:2), 'int16');
dlen = double(len);
ident = char(data(3));
pos = 1;

while len > 0
    
    switch ident
        case '5' % SDataChannel, skip one byte at start
            channel = typecast(data(pos+4:pos+5), 'int16');
            
            if ~isAnalog(channel)
                ttlnum = ttlnums(channel);
                time = typecast(data(pos+6:pos+9), 'uint32');
                yesno = typecast(data(pos+10:pos+11), 'int16');
                if yesno == 0
                    % this is a down event
                    output(event_idx, :) = [ttlnum, time, 0];
                else
                    % this is an up event
                    output(event_idx, :) = [ttlnum, time, 1];
                end
                event_idx = event_idx + 1;
            end
            
        case '2' % SDefChannel, skip one byte at start
            
            % nextBlock = typecast(data(pos+4:pos+7), 'int32');
            t = typecast(data(pos+8:pos+13), 'int16');
            t_isAnalog = t(1);
            % t_isInput = t(2);
            t_numChannel = t(3);
            isAnalog(t_numChannel) = t_isAnalog;
            %SDefChannel(end+1).numChannel = t_numChannel;
            
            % skip 4 bytes for spike color and junk
            if ~t_isAnalog
                
                %channelNum(chnow) = t_numChannel;
                sampling_rates(t_numChannel) = ...
                    typecast(data(pos+18:pos+21), 'single');
                %saveTrigger = typecast(data(pos+22:pos+23), 'int16');
                %duration = typecast(data(pos+24:pos+27), 'single');
                %prev_staus = typecast(data(pos+28:pos+29), 'int16');
                %name = char(data(pos+30:pos+dlen-1))'; % this can be made faster by removing this line
                ttlnums(t_numChannel) = ...
                    str2double(char(data(pos+34:pos+36)));
                %ttlnums{chnow} = name(5:7);
                %SDefChannel(end).name = name;
            end
            
    end
    
    pos = pos + dlen;
    len = typecast(data(pos:(pos+1)), 'int16');
    dlen = double(len);
    ident = char(data(pos+2));
    
end

events = output(1:(event_idx - 1), :);

ttls = unique(ttlnums);
ttls = ttls(ttls ~= 0);

for i = 1:length(ttls)
    ttl = ttls(i);
    t_sr = sampling_rates(ttlnums == ttl)*1000;
    idx = events(:, 1) == ttl;
    
    % transform event times into seconds
    events(idx, 2) = events(idx, 2)/t_sr;
end
