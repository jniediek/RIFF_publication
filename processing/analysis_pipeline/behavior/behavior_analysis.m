function behavior_analysis(behavior_table, out_folder)
%BEHAVIOR_FIGURES Summary of this function goes here
%   Detailed explanation goes here

%% histogram of nosepokes per area
np_port = behavior_table.port(behavior_table.event_type == 'nosepoke');
[count,port] = hist(np_port,unique(np_port));
all_ports = zeros(1,12);
all_ports(port) = count;
perc = all_ports/sum(all_ports);
fig = figure('Position', [0 0 1000 800], 'Visible', 'off');
b=bar(perc([1,2;3,4;5,6;7,8;9,10;11,12]));
b(1,1).FaceColor = [0.9 0.4 0];
b(1,2).FaceColor = [0 0.447 0.741];
for ii = 1:2:12
    text((ii+1)/2-0.2,perc(ii)+0.015,num2str(all_ports(ii),'%3.0f'), 'VerticalAlignment', 'top', 'FontSize', 8);
    text((ii+1)/2+0.15,perc(ii+1)+0.015,num2str(all_ports(ii+1),'%3.0f'), 'VerticalAlignment', 'top', 'FontSize', 8);
end
xlabel('area number');
ylabel('nosepoke %');
legend('food port','water port');
title('Nosepoke percent per port');


fname = fullfile(out_folder, 'nosepokes_per_area.png');
print(fig,'-dpng', '-r300', fname)
close(fig);
log_msg(out_folder, 'save-png', fname);

S.nosepokes_per_port = all_ports;
%% percent rewards per port
rew_port =  behavior_table.port(behavior_table.event_type == 'food' | behavior_table.event_type == 'water');
[count,port] = hist(rew_port,unique(rew_port));
all_ports = zeros(1,12);
all_ports(port) = count;
perc = all_ports/sum(all_ports);
fig = figure('Position', [0 0 1000 800], 'Visible', 'off');
b=bar(perc([1,2;3,4;5,6;7,8;9,10;11,12]));
b(1,1).FaceColor = [0.9 0.4 0];
b(1,2).FaceColor = [0 0.447 0.741];
for ii = 1:2:12
    text((ii+1)/2-0.2,perc(ii)+0.015,num2str(all_ports(ii),'%3.0f'), 'VerticalAlignment', 'top', 'FontSize', 8);
    text((ii+1)/2+0.15,perc(ii+1)+0.015,num2str(all_ports(ii+1),'%3.0f'), 'VerticalAlignment', 'top', 'FontSize', 8);
end
xlabel('area number');
ylabel('reward %');
legend('food','water');
title('Reward percent per port');

fname = fullfile(out_folder, 'rewards_per_area.png');
print(fig,'-dpng', '-r300', fname)
close(fig);
log_msg(out_folder, 'save-png', fname);


S.rewards_per_port = all_ports;
%% inter-reward time
rew_t =  behavior_table.start_t(behavior_table.event_type == 'food' | behavior_table.event_type == 'water');
np_t = behavior_table.start_t(behavior_table.event_type == 'nosepoke');
fig = figure('Position', [0 0 1000 800], 'Visible', 'off');
plot(diff(rew_t));
title('Inter reward time')
ylabel('time, ms');
xlabel('reward #');

fname = fullfile(out_folder, 'inter_reward_time.png');
print(fig,'-dpng', '-r300', fname)
close(fig);
log_msg(out_folder, 'save-png', fname);

S.inter_reward_time = diff(rew_t);

fig = figure('Position', [0 0 1000 800], 'Visible', 'off');
plot(diff(np_t));
title('Inter nosepoke time')
ylabel('time, ms');
xlabel('nosepoke #');

fname = fullfile(out_folder, 'inter_nosepoke_time.png');
print(fig,'-dpng', '-r300', fname)
close(fig);
log_msg(out_folder, 'save-png', fname);

S.inter_np_time = diff(np_t);
%% nosepokes per port along experiment time

rew_port = behavior_table.port(behavior_table.event_type == 'food' | ...
    behavior_table.event_type == 'water');
np_port = behavior_table.port(behavior_table.event_type == 'nosepoke');

fig = figure('Position', [0 0 1000 800], 'Visible', 'on');
hold all;
plot(np_t, np_port, '-*');
plot(rew_t, rew_port, '-*');
legend('nosepoke', 'reward');

fname = fullfile(out_folder, 'nosepokes_reward_along_session.png');
print(fig, fname, '-dpng', '-r300');
log_msg(out_folder, 'save-png', fname);
fname = [fname(1:end-3), 'fig'];
savefig(fig, fname);
log_msg(out_folder, 'save-fig', fname);

close(fig);

%% timing of events along the experiment (in XYZ minute bins)
dt_minutes = 3;
dt= dt_minutes*60; %5 minutes in seconds
food = [];
water = [];
airpuff = [];
nosepoke = [];
t=[];
this_t = 1;
next_t = find(behavior_table.start_t >= behavior_table.start_t(this_t) + dt,1,'first');
while ~isempty(next_t)
    btbl = behavior_table(this_t:next_t,:);
    f = length(find(btbl.event_type == 'food'));
    food = [food f];
    w = length(find(btbl.event_type == 'water'));
    water = [water w];
    ap = length(find(btbl.event_type == 'airpuff'));
    airpuff = [airpuff ap];
    np = length(find(btbl.event_type == 'nosepoke'));
    nosepoke = [nosepoke np];
    mean_t = (btbl.start_t(1)-behavior_table.start_t(1))/60;
    t = [t mean_t];
    this_t = next_t;
    next_t = find(behavior_table.start_t >= behavior_table.start_t(this_t) + dt,1,'first');
end
if this_t < height(behavior_table)
    next_t = height(behavior_table);
    btbl = behavior_table(this_t:next_t,:);
    f = length(find(btbl.event_type == 'food'));
    food = [food f];
    w = length(find(btbl.event_type == 'water'));
    water = [water w];
    ap = length(find(btbl.event_type == 'airpuff'));
    airpuff = [airpuff ap];
    np = length(find(btbl.event_type == 'nosepoke'));
    nosepoke = [nosepoke np];
    mean_t = (btbl.start_t(1)-behavior_table.start_t(1))/60;
    t = [t mean_t];
end
fig = figure('Position', [0 0 1000 800], 'Visible', 'off');
hold all;
plot(t,food,'-','Color',[0.9 0.4 0]);
plot(t,water,'-','Color',[0 0.447 0.741]);
plot(t,airpuff,'-','Color',[0.8 0.675 0]);
plot(t,nosepoke,'-','Color',[0.7 0.7 0.7]);
xlabel('Mean time of block, min');
ylabel('Number of occured events');
legend('food','water','airpuff', 'nosepoke');
title(sprintf('Summary of behavioral events in %d minute blocks', dt_minutes));

fname = fullfile(out_folder, 'events_along_session.png');
print(fig,'-dpng', '-r300', fname)
close(fig);
log_msg(out_folder, 'save-png', fname);

% for posters etc
% fname = fullfile(out_folder, 'events_along_session.fig');
% savefig(fname);

% print(gcf,fname,'-depsc','-tiff')

S.session_stats.t = t;
S.session_stats.nosepoke = nosepoke;
S.session_stats.food = food;
S.session_stats.water = water;
S.session_stats.airpuff = airpuff;

fname = fullfile(out_folder,'behavior_summary.mat');
save(fname, '-struct', 'S');
log_msg(out_folder, 'save-mat', fname);

end

