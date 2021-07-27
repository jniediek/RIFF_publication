function idxs = create_behav_clusters(speed, param)
% JN 2020-12-13, 2020-12-14

r_speed = speed(:, param.cluster_start_samp:param.cluster_stop_samp);

max_speed = max(abs(r_speed), [], 2);
idx_slow = max_speed < param.cluster_thr;

[ma, ~] = max(r_speed, [], 2);
[mi, ~] = max(-r_speed, [], 2);
idx_pos = (ma >= mi) & ~idx_slow;
idx_neg = ~idx_pos & ~idx_slow;

idxs = {idx_slow, idx_pos, idx_neg};