function synth=get_synth_chans(line,right_ear,left_ear)
synth_chans=zeros(1,4);
if (~isempty(findstr('1',right_ear)) || ~isempty(findstr('1',left_ear)))
    synth_chans(1)=1;
end
if (~isempty(findstr('2',right_ear)) || ~isempty(findstr('2',left_ear)))
    synth_chans(2)=1;
end  
if (~isempty(findstr('3',right_ear)) || ~isempty(findstr('3',left_ear)))
    synth_chans(3)=1;
end
if (~isempty(findstr('4',right_ear)) || ~isempty(findstr('4',left_ear)))
    synth_chans(4)=1;
end

synth=synth_chans;

