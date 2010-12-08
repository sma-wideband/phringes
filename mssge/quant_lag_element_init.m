function quant_lag_element_init(blk, varargin)
% Initialize and configure the 4x real FFT biplex.
%
% fft_biplex_real_4x_init(blk, varargin)
%
% blk = The block to configure.
% varargin = {'varname', 'value', ...} pairs
% 
% Valid varnames for this block are:
% demux = Number of parallel streams, (currently only 4 is supported). 
% lag = Value of lag for the current lag element.

% Declare any default values for arguments you might like.
defaults = {};
if same_state(blk, 'defaults', defaults, varargin{:}), return, end
check_mask_type(blk, 'quant_lag_element');
munge_block(blk, varargin{:});

% Get the necessary mask parameters.
demuxr2 = get_var('demux', 'defaults', defaults, varargin{:});
lag = get_var('lag', 'defaults', defaults, varargin{:});
demux = 2^demuxr2;

delete_lines(blk);

% Draw the inputs and initial delay lines.
x0 = 15;
y0 = 23;
dx = 30;
dy = 14;
grp_dy = demux*dy*2.5*2;
for n=1:2
    for i=1:demux
        in_port_name = ['in', num2str(n), '_', num2str(i-1)];
        y = y0 + 1.25*grp_dy*(n-1) + 3*dy*(i-1);
        reuse_block(blk, in_port_name, 'built-in/inport', 'Position', [x0 y x0+dx y+dy], 'Port', num2str(i+demux*(n-1)));
    end
end
reuse_block(blk, 'rst', 'built-in/inport', 'Position', [x0+16*dx 2*grp_dy x0+17*dx 2*grp_dy+dy]);
reuse_block(blk, 'en', 'built-in/inport', 'Position', [x0+16*dx 2*grp_dy+3*dy x0+17*dx 2*grp_dy+4*dy]);

% Draw the multipliers, there is one per demuxed stream, and create the
% interconnects.
for i=1:demux
    mult_name = ['mult', num2str(i)];
    reuse_block(blk, mult_name, 'quant_xcorr_lib/2bit_mult', ...
        'Position', [x0+8*dx y0+(2/demux)*grp_dy*(i-1) x0+9*dx y0+(2/demux)*grp_dy*(i-1)+(1/demux)*grp_dy]);
    add_line(blk, ['in1_', num2str(i-1), '/1'], [mult_name, '/1']);
    add_line(blk, ['in2_', num2str(i-1), '/1'], [mult_name, '/2']);
end

% Now draw the layers of adders and create all the interconnects.
for i=1:demuxr2
    for j=1:(demux/(2^i))
        adder_name = ['add', num2str(i), '_', num2str(j)];
        reuse_block(blk, adder_name, 'xbsIndex_r4/AddSub', ...
            'Position', [x0+10*dx+3*dx*i y0+(grp_dy*i/16)*(i-1)+((4*i)/demux)*grp_dy*(j-1) ...
            x0+3*dx*i+11*dx y0+(grp_dy*i/16)*(i-1)+((4*i)/demux)*grp_dy*(j-1)+(2*i/demux)*grp_dy], ...
            'latency', '1', 'pipeline', 'yes');
        if i==1
            add_line(blk, ['mult', num2str(2*j-1), '/1'], [adder_name, '/1']);
            add_line(blk, ['mult', num2str(2*j), '/1'], [adder_name, '/2']);
        else
            add_line(blk, ['add', num2str(i-1), '_', num2str(2*j-1), '/1'], [adder_name, '/1']);
            add_line(blk, ['add', num2str(i-1), '_', num2str(2*j), '/1'], [adder_name, '/2']);
        end
    end            
end

% Now draw the accumulator and connect the last element in the chain to it,
% as well as the rst and en ports.
if demux==1
    lastel_name = 'mult1';
else
    lastel_name = ['add',num2str(demuxr2), '_1'];
end
acc_name = ['accumul', num2str(lag)];
reuse_block(blk, acc_name, 'xbsIndex_r4/Accumulator', 'Position', [x0+(15+3*demuxr2)*dx y0+0.75*grp_dy ...
    x0+(17+3*demuxr2)*dx y0+0.85*grp_dy], 'n_bits', '32', 'en', 'yes', 'overflow', 'Saturate');
reuse_block(blk, 'acc_out', 'built-in/outport', 'Position', [x0+(19+3*demuxr2)*dx y0+0.75*grp_dy ...
    x0+(20+3*demuxr2)*dx y0+dy+0.75*grp_dy], 'Port', '1');
add_line(blk, [lastel_name, '/1'], [acc_name, '/1']);
add_line(blk, [acc_name, '/1'], ['acc_out', '/1']);
add_line(blk, ['rst', '/1'], [acc_name, '/2']);
add_line(blk, ['en', '/1'], [acc_name, '/3']);

% Clean blocks and finish up.
clean_blocks(blk);

fmtstr = sprintf('demux=%d, lag=%d', demux, lag);
set_param(blk, 'AttributesFormatString', fmtstr);
save_state(blk, 'defaults', defaults, varargin{:});
