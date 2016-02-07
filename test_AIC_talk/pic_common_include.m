% pic common include

if exist('b_read_pic_option', 'var') && b_read_pic_option
    global pic_prefix;
    global pic_output;
    global pic_output_color;
    global fontsize;
    global linewidth;
else
    global pic_prefix;
    global pic_output;
    global pic_output_bw;
    global pic_output_png;
    global fontsize;
    global linewidth;
    % whether we are in Octave or Matlab
    is_octave = exist('OCTAVE_VERSION','builtin') ~= 0;
    if is_octave
        fontsize = 22;
        linewidth = 3;
    else
        fontsize = 12;
        linewidth = 1;
    end
    pic_prefix = 'pic_tmp/';
    pic_output_bw  = @(st)print('-deps',  [pic_prefix, st, '.eps']);
    pic_output     = @(st)print('-depsc2',[pic_prefix, st, '.eps']);
    pic_output_png = @(st)print('-dpng',  [pic_prefix, st, '.png']);
%    set(0, 'defaultfigurevisible', 'off');
    %figure(100, 'visible', 'off');
    set(0, 'defaultlinelinewidth', linewidth);
    set(0, 'defaultaxesfontsize', fontsize);
end

