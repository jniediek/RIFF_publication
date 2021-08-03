% function [T, paramF] = createSilenceRows(Told,paramFold,nrows,trdur)
% 
% type = cell(nrows, 1);
% type(:) = {'silence'};
% type = categorical(type);
% speaker = ones(nrows,1)*3;
% samp_rate = ones(nrows,1)*192000;
% trial_dur = ones(nrows,1)*trdur;
% stime = zeros(nrows,1);
% etime = zeros(nrows,1);
% ramp = zeros(nrows,1);
% % played = zeros(nrows,1);
% played = cell(nrows, 1);
% played(:) = {'no'};
% played = categorical(played,{'yes','no'});
% phase = zeros(nrows,1);
% 
% Tsize = size(Told,1);
% paramsize = size(paramFold,1);
% 
% paramline = (paramsize+1:paramsize+nrows)';
% Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
% T = [Told; Tnew];
% 
% line = (Tsize+1:Tsize+nrows)';
% paramFnew = table(line, freq, phase);
% paramF = [paramFold; paramFnew];
% 
