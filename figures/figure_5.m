%% stimuli sensitive units (5a-d)
load(fullfile('..','data','auditory_units.mat'));
unitnum = [16,2,5,2];
sounds = [10,1,5,1];
ylimsize = [2,10,8,10];
xlimsize = [1500,2500,1000,1000];
t = linspace(0,2500,192000*2.5);
figure('Position',[100,100,1500,800]);
loc = [3,4,2,1];
for day = 1:4
    tsounds = data(loc(day)).sound_t;
    ts = data(loc(day)).start_t;
    te = data(loc(day)).end_t;
    ui = data(loc(day)).NA_t;
    uts = find(ui >= ts,1,'first');
    ute = find(ui <= te,1,'last');
    ubn = ui(uts:ute);
    snames = unique(data(loc(day)).sound_names);
    all_locs = cell(1,length(snames));
    nums = [];
    kk=1;
    subplot(2,4,day)
    hold all;
    for ii = 1:length(tsounds)
        si = find(ubn >= tsounds(ii)-0.5 & ubn <= tsounds(ii)+2);
        sidx = find(snames == data(loc(day)).sound_names(ii+5)); %sounds_table.soundname(ii+5)
        locs = ubn(si)-tsounds(ii);
        all_locs{sidx} = [all_locs{sidx}; locs];
        if sidx == sounds(loc(day))
            plot(locs, ones(1,length(locs))*ii,'.k');
        end
    end
    xlim([0,xlimsize(loc(day))/1000]);
    title(['unit #',num2str(unitnum(loc(day)))])
    clear N
    for jj = 1:length(all_locs)
        [N(jj,:),~] = histcounts(all_locs{jj},2500);
    end    
    subplot(2,4,day+4)
    hold all;    
    plot(smooth(N(sounds(loc(day)),:),11),'k');
    plot(t,data(loc(day)).sound-2,'color',[1 1 1]*0.3);
    line([500 500],[0 max(N(sounds(loc(day)),:))+0.1],'Color','r','LineWidth',2)    
    xlabel('time, ms');
    ylim([-5 ylimsize(loc(day))]);
    xlim([0,xlimsize(loc(day))]);
end
%% location sensitive units (5e-h)
load(fullfile('..','data','location_sensitive_units.mat'));
binsize = 12;
unitnum = {'118','107','210','302'};
clear ran err
figure('Position', [100, 100, 2000, 600]);
for ui = 1:length(unitnum)
    seldata = data(data.unit == unitnum{ui},:);
    seldata.rat_angs(seldata.rat_angs < 0) = 2*pi+seldata.rat_angs(seldata.rat_angs < 0);
    [aa,ad] = discretize(seldata.rat_angs,binsize);
    seldata.angs = aa;
    ran{ui} = zeros(1,binsize);
    err{ui} = zeros(1,binsize);
    for ii = 1:binsize
            ran{ui}(ii) = mean(seldata.resp(find(seldata.angs == ii)));
            err{ui}(ii) = std(seldata.resp(find(seldata.angs == ii)))/sqrt(length(find(seldata.angs == ii)));
    end
    subplot(1,4,ui)
    polarhistogram('binedges',ad*pi/180,'bincounts',ran{ui}/max(ran{ui}),'facecolor','k','edgecolor','none');
    hold all;
    ll{ui} = sqrt(histcounts(aa,binsize));
    la = ad(1:end-1)+diff(ad)/2;
    polarplot([la la(1)]*pi/180,[ll{ui} ll{ui}(1)]/max(ll{ui}),'color',[1 1 1]*0.8,'LineWidth',4);
    title(['unit #',unitnum{ui}]);
end
%% relative turn angle sensitive units (5i-l)
load(fullfile('..','data','angle_sensitive_units.mat'));
binsize = 12;
unitnum = {'602','102','207','302'}; % we eventually didn't use the data from R5,290620, unit #1, or R7,290420, u #8
figure('Position', [100, 100, 2000, 600]);
for jj = 1:length(unitnum) 
    seldata = data(data.unit == unitnum(jj),:);
    sel=abs(seldata.relative_turn_angles)>100; % angles above 100 deg don't make sense (this is an arbitrary cutoff)  
    seldata.relative_turn_angles(sel) = 100;
    [ai,as] = discretize(seldata.relative_turn_angles,binsize); %divide  angles into [binsize] bins of equal size
    seldata.binned_rel_turn_angs = ai;
    iii = 0;
    for ii = 2:binsize-1
        iii = iii+1;
        if ii == 2
            mrs{jj}(iii) = mean(seldata.resp(seldata.binned_rel_turn_angs == ii | seldata.binned_rel_turn_angs == ii-1));
        elseif ii == binsize-1
            mrs{jj}(iii) = mean(seldata.resp(seldata.binned_rel_turn_angs == ii | seldata.binned_rel_turn_angs == ii+1));
        else
            mrs{jj}(iii) = mean(seldata.resp(seldata.binned_rel_turn_angs == ii));  %mean of bin
        end
    end
    subplot(1,4,jj)
    ass = as([1,3:binsize-2,binsize:binsize+1]);
    polarhistogram('binedges',ass*pi/180,'bincounts',mrs{jj}/max(mrs{jj}),'edgecolor','none','facecolor','k') %polar histogram of the 10 bins, normalized
    pax = gca;
    pax.ThetaZeroLocation = 'top';
    pax.ThetaLim = [-180 180];
    title([' unit #',unitnum{jj}]);
end
