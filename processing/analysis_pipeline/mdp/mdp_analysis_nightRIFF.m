function mdp_analysis_nightRIFF(sounds_table, mdp_table, outputdir)

if sum(mdp_table.type == 'playSound')
    %sounds played in session
    pSi = find(mdp_table.type == 'playSound');
    pSii = find(diff(pSi) > 1);
    pSarea = mdp_table.s_area(pSi(pSii)+1);
    fig = figure('Position', [0 0 1000 800], 'Visible', 'off');
    histogram(pSarea)
    title('Sounds played throughout the session');
    fname = fullfile(outputdir, 'played_sounds.png');
    print(fig,'-dpng', '-r300', fname)
    close(fig);
    %sounds rewarded in session
    rewi = find(mdp_table.behavior == 'reward');
    rewarea = mdp_table.s_area(rewi);
    fig = figure('Position', [0 0 1000 800], 'Visible', 'off');
    histogram(rewarea)
    title('Sounds rewarded throughout the session');
    fname = fullfile(outputdir, 'rewarded_sounds.png');
    print(fig,'-dpng', '-r300', fname)
    close(fig);
    %nosepoking during sounds vs. silence
    ar = find(diff(mdp_table.area));
    snp = zeros(2,2,6);
    times = zeros(2,2,6);
    for ii =1:length(ar)-1
        tmpT = mdp_table(ar(ii)+1:ar(ii+1),:);
        ari = tmpT.area(1);
        if ~isempty(find(tmpT.type == 'playSound'))
            snp(1,1,ari) = snp(1,1,ari)+1;
            times(1,1,ari) = times(1,1,ari)+tmpT.start_t(end)-tmpT.start_t(1);
            if ~isempty(find(tmpT.action & tmpT.type ~= 'timeout'))
                snp(2,1,ari) = snp(2,1,ari)+1;
                times(2,1,ari) = times(2,1,ari)+tmpT.start_t(end)-tmpT.start_t(1);
            end
        else
            snp(1,2,ari) = snp(1,2,ari)+1;
            times(1,2,ari) = times(1,2,ari)+tmpT.start_t(end)-tmpT.start_t(1);
            if ~isempty(find(tmpT.action))
                snp(2,2,ari) = snp(2,2,ari)+1;
                times(2,2,ari) = times(2,2,ari)+tmpT.start_t(end)-tmpT.start_t(1);
            end
        end
    end
    times = times/60;
    soundi = find(sounds_table.soundname ~= 'silence');
    sounds_played = sum(sounds_table.start_t(soundi(1:end-1)+1)-sounds_table.start_t(soundi(1:end-1)))/3600;
    total_time = (sounds_table.start_t(end)-sounds_table.start_t(1))/3600;
    silence_time = total_time - sounds_played;
    fileID = fopen(fullfile(outputdir,'sound_nosepoke_info.txt'),'w');
    fprintf(fileID, 'Information about nosepokes and sound presentations:\n\n');
    fprintf(fileID, 'Total session time: %4.2f hours\n',total_time);
    fprintf(fileID, 'Total sound time: %4.2f hours\n',sounds_played);
    fprintf(fileID, 'Total silence time: %4.2f hours\n',silence_time);
    fprintf(fileID, 'Occurences in each area:\n\n');
    for ii = 1:6
        fprintf(fileID, 'Area: %d\n\n',ii);
        fprintf(fileID, '\t\tsound played\tsilence\n');
        fprintf(fileID, 'Total:\t\t%d\t\t%d\n',snp(1,1,ii),snp(1,2,ii));
        fprintf(fileID, 'Nosepokes:\t%d\t\t%d\n',snp(2,1,ii),snp(2,2,ii));
        fprintf(fileID, 'No nosepokes:\t%d\t\t%d\n',snp(1,1,ii)-snp(2,1,ii),snp(1,2,ii)-snp(2,2,ii));
        fprintf(fileID, 'Time spent during visits in area (in minutes):\n');
        fprintf(fileID, 'Total:\t\t%4.2f\t\t%4.2f\n',times(1,1,ii),times(1,2,ii));
        fprintf(fileID, 'Nosepokes:\t%4.2f\t\t%4.2f\n',times(2,1,ii),times(2,2,ii));
        fprintf(fileID, 'No nosepokes:\t%4.2f\t\t%4.2f\n\n',times(1,1,ii)-times(2,1,ii),times(1,2,ii)-times(2,2,ii));
    end
    fclose(fileID);
elseif sum(mdp_table.type == 'center')
    % cam stuff
    %         cam_name = dir(fullfile(outputdir,'*_camera_analyzed_data.mat'));
    %         load(fullfile(cam_name.folder,cam_name.name));
    %         h_f = figure('Position', [100, 100, 1090, 820], 'Visible', 'on');
    %         h_ax = axes(h_f);
    %         h_im = imshow(cat(3, bg_image, bg_image, bg_image), 'parent', h_ax, 'InitialMagnification', 'fit');
    %         hold(h_ax, 'on');
    %         h_ax.Visible = 'off';
    % -----
    cent = find(mdp_table.type == 'center');
    len = length(cent);
    shift = 0;
    tr_suc = zeros(3,len);
    punish = 0;
    punish_tr = 0;
    ftr = zeros(2,len);
    ptime = zeros(1,len);
    %         loc = zeros(1,len);
    %         pokes = cell(len,1);
    %         strial=0;
    %         atmpT=[];
    for ii = shift+(1:len)
        jj = find(mdp_table.type(cent(ii):end) == 'wait',1,'first');
        if isempty(jj)
            jj = height(mdp_table)-cent(ii);
        end
        if ii == 1
            kk = 1;
        else
            kk = cent(ii-1);
        end
        prevT = mdp_table(kk:cent(ii)-1,:);
        if ~isempty(find(prevT.action,1,'last'))
            ftr(1,ii-shift) = prevT.action(find(prevT.action,1,'last'));
        end
        tmpT = mdp_table(cent(ii):cent(ii)+jj-1,:);
        tr_suc(3,ii-shift) = tmpT.s_area(find(tmpT.soundIsPlaying,1,'first'));
        %             if ~isempty(find(tmpT.type(2:end)=='center'))
        %                 strial=strial+1;
        %                 atmpT{end+1}=tmpT;
        %             end
        if tmpT.behavior(end) == 'reward'
            tr_suc(2,ii-shift) = tmpT.action(find(tmpT.action,1,'last'));
            %                 if tmpT.s_area(end) == 3     %randomly chosen to show pokes in area 2
            %                     ti = find(tmpT.start_t >= tmpT.start_t(1)+2,1,'first');
            %                     hline = scatter3(tmpT.loc_x(1:ti), tmpT.loc_y(1:ti),(1:ti), 50, 'filled');
            %                 end
            %             elseif tmpT.s_area(end) == 3
            %                 ti = find(tmpT.start_t >= tmpT.start_t(1)+2,1,'first');
            %                 hline = scatter3(tmpT.loc_x(1:ti), tmpT.loc_y(1:ti),(1:ti), 50,'d','LineWidth',1.5);
        end
        if tmpT.type(2) == 'noNPWait'
            punish_tr = punish_tr+1;
            if tmpT.behavior(end) == 'punish'
                punish(1,punish_tr) = 1;
            else
                punish(1,punish_tr) = 0;
            end
            ti = find(tmpT.start_t >= tmpT.start_t(1)+9,1,'first');
            hline = scatter3(tmpT.loc_x(1:ti), tmpT.loc_y(1:ti),(1:ti), 50, 'filled');
        end
        if ~isempty(find(tmpT.action,1,'first'))
            ftr(2,ii-shift)=tmpT.action(find(tmpT.action,1,'first'));
            %                 loc(ii-shift) = getFuncArea(tmpT.loc_x(1),tmpT.loc_y(1),area_table);
            ptime(ii-shift) = tmpT.start_t(find(tmpT.action,1,'first')) - tmpT.start_t(1);
        end
        tr_suc(1,ii-shift)=length(find(unique(tmpT.action)));
        %             pokes{ii} = tmpT.action(find(unique(tmpT.action))
    end
    fia=floor((ftr(2,:)-1)/2)+1;
    x = crosstab(fia,tr_suc(3,:));
    ar_nums = unique(tr_suc(3,:));
    areas = length(ar_nums);
    fig = figure('Position', [0 0 900 800], 'Visible', 'on');
    if size(x,1) > areas
        if size(x,2) > areas
            imagesc(x(2:areas+1,2:areas+1));
        else
            imagesc(x(2:areas+1,:));
        end
    else
        imagesc(x);
    end
    for ii = 1:areas
        ar_names{ii} = num2str(ar_nums(ii));
    end
    xlabel('sound played');
    ylabel('area poked');
    set(gca,'XTick',1:areas,'XTickLabel',ar_names,'YTick',1:areas,'YTickLabel',ar_names)
    c = colorbar();
    c.Label.String = 'number of pokes';
    c.Label.FontSize = 12;
    fname = fullfile(outputdir, 'area_poked_sound_played.png');
    print(fig,'-dpng', '-r300', fname)
    close(fig);
    fig = figure('Position', [0 0 1000 800], 'Visible', 'on');
    histogram(tr_suc(1,:));
    hold all;
    histogram(tr_suc(1,find(tr_suc(2,:))));
    legend('all trials','successful trials')
    title(['Total trials: ',num2str(length(cent)),', rewarded trials: ',num2str(length(tr_suc(1,find(tr_suc(2,:))))),...
        '. Punished trials: Nos.',num2str(find(punish)),' out of ',num2str(punish_tr),' punishment trials. '...
        'Total missed trials: ',num2str(length(find(fia == 0)))]);
    xlabel('# tries per trial');
    fname = fullfile(outputdir, 'tries_in_trial.png');
    print(fig,'-dpng', '-r300', fname)
    close(fig);
    iti = mdp_table.start_t(cent(2:end))-mdp_table.start_t(cent(1:end-1));
    fig = figure('Position', [0 0 1000 800], 'Visible', 'on');
    subplot(1,2,1)
    histogram(iti,length(iti));
    title('Whole picture')
    xlabel('time, s');
    subplot(1,2,2);
    histogram(iti,length(iti));
    xlim([0 400])
    title('Closeup')
    xlabel('time, s');
    
    % JN 2020-04-26
    % suptitle is part of the bioinformatics toolbox, I don't have it
    % at home...
    %suptitle('Inter trial intervals (time between two visits in the center of the arena)');
    
    fname = fullfile(outputdir, 'inter_trial_intervals.png');
    print(fig,'-dpng', '-r300', fname)
    close(fig);
    %         uiopen(fullfile(outputdir,'nosepokes_reward_along_session.fig'),1);
    %         stimes = sounds_table.start_t;
    %         hold on;
    %         line(stimes*[1 1],[1 11],'col','k');
    %         fname = fullfile(outputdir, 'nosepokes_reward_along_session_with_sound_onsets.fig');
    %         savefig(gcf,fname);
    %if it's Up-Down-Design
    if size(sounds_table.att(1,:),2) == 12
        att = max(sounds_table.att,[],2);
        slines = mdp_table.sline(cent+1);
        atts = att(slines);
        aa = find(tr_suc(2,:));
        fig = figure('Position', [0 0 1000 800], 'Visible', 'on');
        sucol = [0.302 0.533 1];
        facol = [1 0.6 0.2];
        hold all;
        for kk = 1:length(atts)
            if find(aa==kk)
                plot(kk,atts(kk)-20,'*','MarkerEdgeColor',sucol)
            else
                plot(kk,atts(kk)-20,'*','MarkerEdgeColor',facol)
            end
        end
        xlabel('trial #');
        ylabel('dB attenuation of non-target speakers');
        title('Non target speaker attenuation in up-down design protocol');
        fname = fullfile(outputdir, 'non_target_attenuation_in_UDD.png');
        print(fig,'-dpng', '-r300', fname)
        close(fig);
    end
    %if it's a control trial
    if sum(contains(sounds_table.Properties.VariableNames,'blocktype'))
        sline = mdp_table.sline(cent+1);
        block = sounds_table.blocktype(sline);
        reg = find(block == 'regular');
        cntrl = find(block == 'control_1s');
        block_loc{1} = reg';
        block_loc{2} = cntrl';
        block_name = {'regular','control_1s'};
        for bi = 1:2
            len = length(block_loc{bi});
            tr_suc = zeros(3,len);
            ftr = zeros(2,len);
            for ii = 1:length(block_loc{bi})
                jj = find(mdp_table.type(cent(block_loc{bi}(ii)):end) == 'wait',1,'first');
                if isempty(jj)
                    jj = height(mdp_table)-cent(block_loc{bi}(ii));
                end
                if ii == 1
                    kk = 1;
                else
                    kk = cent(block_loc{bi}(ii)-1);
                end
                prevT = mdp_table(kk:cent(block_loc{bi}(ii))-1,:);
                if ~isempty(find(prevT.action,1,'last'))
                    ftr(1,ii-shift) = prevT.action(find(prevT.action,1,'last'));
                end
                tmpT = mdp_table(cent(block_loc{bi}(ii)):cent(block_loc{bi}(ii))+jj-1,:);
                tr_suc(3,ii-shift) = tmpT.s_area(find(tmpT.soundIsPlaying,1,'first'));
                if tmpT.behavior(end) == 'reward'
                    tr_suc(2,ii-shift) = tmpT.action(find(tmpT.action,1,'last'));
                end
                if ~isempty(find(tmpT.action,1,'first'))
                    ftr(2,ii-shift)=tmpT.action(find(tmpT.action,1,'first'));
                end
                tr_suc(1,ii-shift)=length(find(unique(tmpT.action)));
            end
            fia=floor((ftr(2,:)-1)/2)+1;
            x = crosstab(fia,tr_suc(3,:));
            fig = figure('Position', [0 0 900 800], 'Visible', 'on');
            if size(x,1) > 6
                if size(x,2) > 6
                    imagesc(x(2:7,2:7));
                else
                    imagesc(x(2:7,:));
                end
            else
                imagesc(x);
            end
            xlabel('sound played');
            ylabel('area poked');
            c = colorbar();
            c.Label.String = 'number of pokes';
            c.Label.FontSize = 12;
            fname = fullfile(outputdir, ['area_poked_sound_played_',block_name{bi},'_cond.png']);
            print(fig,'-dpng', '-r300', fname)
            close(fig);
            fig = figure('Position', [0 0 1000 800], 'Visible', 'on');
            histogram(tr_suc(1,:));
            hold all;
            histogram(tr_suc(1,find(tr_suc(2,:))));
            legend('all trials','successful trials')
            title(['Total trials in block: ',num2str(length(tr_suc)),', successful trials: ',num2str(length(tr_suc(1,find(tr_suc(2,:)))))]);
            xlabel('# tries per trial');
            fname = fullfile(outputdir, ['tries_in_trial_',block_name{bi},'_cond.png']);
            print(fig,'-dpng', '-r300', fname)
            close(fig);
        end
    end
end