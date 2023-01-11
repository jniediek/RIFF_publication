function print_plot_to_file(h_f, name, mdata)
if ~mdata.do_print
    return;
end
full_name = strcat(name, '.png');
res = '-r450';
print(h_f, full_name, '-dpng', res);

if isfield(mdata, 'do_close_all') && mdata.do_close_all
    drawnow(); % Allow the drawing and saving to finish
    close(h_f);
end
end