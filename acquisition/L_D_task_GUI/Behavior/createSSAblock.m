function [T, paramF] = createSSAblock(Told,paramFold,bf,ssa_att)
% 2000<=bf<=35000 !!!!!!!
df=2^(1/6);
% params-------------------------------------------------------------------
type = cell(500, 1);
type(:) = {'freq'};
speaker = ones(500,1)*3;
samp_rate = ones(500,1)*192000;
trial_dur = ones(500,1)*300;
stime = ones(500,1)*50;
etime = ones(500,1)*80;
ramp = ones(500,1)*5;
% att = ones(500,1)*ssa_att; %written in each one
% played = zeros(500,1);
played = cell(500, 1);
played(:) = {'no'};
played = categorical(played,{'yes','no'});
phase = zeros(500,1);
% shuffle all -------------------------------------------------------------
blocks = {'H','L','1','2','E','D','M'};
inds = randperm(length(blocks));
blocks = blocks(inds);

for i = 1:length(blocks)
    switch blocks{i}
%H ------------------------------------------------------------------------
        case 'H'
            Tsize = size(Told,1);
            paramsize = size(paramFold,1);
            att = ones(500,1)*ssa_att;
            
            paramline = (paramsize+1:paramsize+500)';
            Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att,paramline,played);
            Told = [Told; Tnew];
            
            n = randi(1000,1);
            rng(n,'twister');
            freq = ones(500,1)*bf*df;
            freq(randsample(500,25)) = bf/df;
            
            line = (Tsize+1:Tsize+500)';
            paramFnew = table(line, freq, phase);
            paramFold = [paramFold; paramFnew];
            
            [Told, paramFold] = createSILblock(Told,paramFold);
%L-------------------------------------------------------------------------
        case 'L'
            Tsize = size(Told,1);
            paramsize = size(paramFold,1);
            att = ones(500,1)*ssa_att;

            paramline = (paramsize+1:paramsize+500)';
            Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
            Told = [Told; Tnew];
            
            n = randi(1000,1);
            rng(n,'twister');
            freq = ones(500,1)*bf*df;
            freq(randsample(500,475)) = bf/df;
            line = (Tsize+1:Tsize+500)';
            paramFnew = table(line, freq, phase);
            paramFold = [paramFold; paramFnew];
            
            [Told, paramFold] = createSILblock(Told,paramFold);
%E-------------------------------------------------------------------------
        case 'E'
            Tsize = size(Told,1);
            paramsize = size(paramFold,1);
            att = ones(500,1)*ssa_att;

            paramline = (paramsize+1:paramsize+500)';
            Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
            Told = [Told; Tnew];
            
            n = randi(1000,1);
            rng(n,'twister');
            freq = ones(500,1)*bf*df;
            freq(randsample(500,250)) = bf/df;
            line = (Tsize+1:Tsize+500)';
            paramFnew = table(line, freq, phase);
            paramFold = [paramFold; paramFnew];
            
            [Told, paramFold] = createSILblock(Told,paramFold);
%1-------------------------------------------------------------------------
        case '1'
            Tsize = size(Told,1);
            paramsize = size(paramFold,1);
            att = ones(500,1)*ssa_att;

            n = randi(1000,1);
            rng(n,'twister');
            freq = ones(500,1)*bf*df;
            att(randsample(500,475)) = 120;            
            
            paramline = (paramsize+1:paramsize+500)';
            Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
            Told = [Told; Tnew];
            
            line = (Tsize+1:Tsize+500)';
            paramFnew = table(line, freq, phase);
            paramFold = [paramFold; paramFnew];
            
            [Told, paramFold] = createSILblock(Told,paramFold);
%2-------------------------------------------------------------------------
        case '2'
            Tsize = size(Told,1);
            paramsize = size(paramFold,1);
            att = ones(500,1)*ssa_att;

            n = randi(1000,1);
            rng(n,'twister');
            freq = ones(500,1)*bf/df;
            att(randsample(500,475)) = 120;
            
            
            paramline = (paramsize+1:paramsize+500)';
            Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
            Told = [Told; Tnew];
            
            line = (Tsize+1:Tsize+500)';
            paramFnew = table(line, freq, phase);
            paramFold = [paramFold; paramFnew];
            
            [Told, paramFold] = createSILblock(Told,paramFold);
%D-------------------------------------------------------------------------
        case 'D'
            Tsize = size(Told,1);
            paramsize = size(paramFold,1);
            att = ones(500,1)*ssa_att;

            paramline = (paramsize+1:paramsize+500)';
            Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
            Told = [Told; Tnew];
            
            n = randi(1000,1);
            rng(n,'twister');
            freq = linspace(bf/df^(19/11),bf*df^(19/11),20);
            freq = repmat(freq,1,25);
            freq = freq(randperm(length(freq)))';
            
            line = (Tsize+1:Tsize+500)';
            paramFnew = table(line, freq, phase);
            paramFold = [paramFold; paramFnew];
            
            [Told, paramFold] = createSILblock(Told,paramFold);
 %M-------------------------------------------------------------------------
        case 'M'
            Tsize = size(Told,1);
            paramsize = size(paramFold,1);
            att = ones(500,1)*ssa_att;

            paramline = (paramsize+1:paramsize+500)';
            Tnew = table(type,speaker,samp_rate,trial_dur,stime,etime,ramp,att, paramline,played);
            Told = [Told; Tnew];
            
            n = randi(1000,1);
            rng(n,'twister');
            
            if bf <= 3000
                freq = [repmat([-5,-3,3:2:17],1,45) repmat([-1 1],1,25)];
            elseif bf >= 20000
                freq = [repmat([-17:2:-3,3,5],1,45) repmat([-1 1],1,25)];
            else
                freq = [repmat([-11:2:-3,3:2:11],1,45) repmat([-1 1],1,25)];
            end
            freq = freq(randperm(length(freq)));
            freq = bf*df.^(freq)';
            
            line = (Tsize+1:Tsize+500)';
            paramFnew = table(line, freq, phase);
            paramFold = [paramFold; paramFnew];
            
            [Told, paramFold] = createSILblock(Told,paramFold);
%--------------------------------------------------------------------------
    end
%     % Now add 10 seconds of silence
%     nstims=33;
%     Tsize = size(Told,1);
%     paramsize = size(paramFold,1);
%     type = cell(nstims, 1);
%     type(:) = {'freq'};
%     type = categorical(type);
%     
%     paramline = (paramsize+1:paramsize+nstims)';
%     silatt=ones(nstims,1)*120;
%     Tnew = table(type,speaker(1:nstims),samp_rate(1:nstims),trial_dur(1:nstims),stime(1:nstims),...
%         etime(1:nstims),ramp(1:nstims),silatt, paramline,played(1:nstims),...
%         'VariableNames',{'type','speaker','samp_rate','trial_dur','stime','etime','ramp','att','paramline','played'});
%     Told = [Told; Tnew];
%     
%     n = randi(1000,1);
%     rng(n,'twister');
%     freq = ones(nstims,1)*5000;
%     
%     line = (Tsize+1:Tsize+nstims)';
%     paramFnew = table(line, freq, phase(1:nstims),'VariableNames',{'line','freq','phase'});
%     paramFold = [paramFold; paramFnew];
end

T = Told;
paramF = paramFold;