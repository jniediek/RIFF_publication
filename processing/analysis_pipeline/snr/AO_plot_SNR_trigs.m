function AO_plot_SNR_trigs(snr_times, output_folder)
    % Function that plots the four trigger types logged by SNR along single time axis.
    h_f = figure('position', [30, 550, 1050, 530], 'visible', 'off');
    h_ax = axes(h_f);
    event_types = {'state', 'snd', 'cam', 'bhv', 'SNR file number'};
    for i = 1:4
        curr_data = snr_times.Time(snr_times.EventType == event_types{i});
        plot(h_ax, curr_data, curr_data*0 + i, '.');
        hold(h_ax, 'on');
    end
    plot(h_ax, snr_times.Time, snr_times.FromFileNo + 5, '.');
%     ylim(h_ax, [0 5]);
    legend(h_ax, event_types, 'location', 'northwest');
    h_ax.XAxis.Exponent = 0;
    h_ax.YAxis.TickValues = [1:4 8];
    h_ax.YAxis.TickLabels = event_types;
    h_ax.XLabel.String = 'Time (sec)';

    if nargin == 2
        f_name = 'raw_SNR_trigs.png';
        print(h_f, fullfile(output_folder, f_name), '-dpng', '-r450');
        close(h_f);
    end
end
