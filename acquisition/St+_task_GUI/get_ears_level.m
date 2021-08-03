% get_ears_level: Currently, just return the attenuation level of each
% channel
% ELN 311214
function [levels_arr,relevant_pa5]=get_ears_level(line,atten_arr)
levels_arr=atten_arr;
relevant_pa5=1:4;
% 
% right_ear=get(line,'Right_ear');
% left_ear=get(line,'Left_ear');
% right_synth_chans=get_synth_chans(line,right_ear,[]);
% left_synth_chans=get_synth_chans(line,[],left_ear);
% right_synth=find(right_synth_chans==1);
% left_synth=find(left_synth_chans==1);
% inter=intersect(right_synth,left_synth);
% both_ears=union(right_synth,left_synth);
% 
% if ~isempty(inter)%their are common channels for left ear and right ear
%     min_atten=min(atten_arr(both_ears));
%     atten_arr(both_ears)=atten_arr(both_ears)-min_atten;
%      relevant_pa5=[both_ears,5,6];
%     levels_arr=[atten_arr,min_atten,min_atten];
% else%their are no common channels for left ear and right ear
%     relevant_pa5=[both_ears];
%     levels_arr=[atten_arr];
%     if (~strcmp(left_ear,'SILENCE'))
%          l_min_atten=min(atten_arr(left_synth));
%         atten_arr(left_synth)=atten_arr(left_synth)-l_min_atten;
%        relevant_pa5=[ relevant_pa5,5];
% 
%     else
%         l_min_atten=0;
%     end
%     if (~strcmp(right_ear,'SILENCE')) 
%         r_min_atten=min(atten_arr(right_synth));
%         atten_arr(right_synth)=atten_arr(right_synth)-r_min_atten;
%         relevant_pa5=[ relevant_pa5,6];
% 
%     else
%         r_min_atten=0;
%     end
%         levels_arr=[atten_arr,l_min_atten,r_min_atten];
% end
% 
% end