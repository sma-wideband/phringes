function quant_cross_corr_init(blk, varargin)
% Initialize and configure the time-domain cross correlator
%
% cross_corr_init(blk, varargin)
%
% blk = The block to configure.
% varargin = {'varname', 'value', ...} pairs
% 
% Valid varnames for this block are:
% demuxr2 = Number of parallel streams (2^?). 
% bits = bitwidth of each parallel stream.
% lags = Array of lags requested.
% range = whether both pos and neg lags are included.

% Declare any default values for arguments you might like.
defaults = {};
if same_state(blk, 'defaults', defaults, varargin{:}), return, end
check_mask_type(blk, 'quant_cross_corr');
munge_block(blk, varargin{:});

% Get the necessary mask parameters.
ants        = get_var('ants', 'defaults', defaults, varargin{:});
demuxr2     = get_var('demuxr2', 'defaults', defaults, varargin{:});
bits        = get_var('bits', 'defaults', defaults, varargin{:});
lags        = get_var('lags', 'defaults', defaults, varargin{:});
range       = get_var('range', 'defaults', defaults, varargin{:});
demux       = 2^demuxr2;
lags        = lags*demux;

delete_lines(blk);

% Create the inputs and tap-off points.
reuse_block(blk, 'rst', 'built-in/inport', 'Position', [30 20 60 34], 'Port', '1');
reuse_block(blk, 'reset', 'built-in/Goto', 'Position', [90 20 140 34], 'GotoTag', 'reset', 'ShowName', 'off');
reuse_block(blk, 'en', 'built-in/inport', 'Position', [30 60 60 74], 'Port', '2');
reuse_block(blk, 'enable', 'built-in/Goto', 'Position', [90 60 140 74], 'GotoTag', 'enable', 'ShowName', 'off');
add_line(blk, 'rst/1', 'reset/1');
add_line(blk, 'en/1', 'enable/1');

for i=1:ants
    for j=1:demux
        in_name = ['in', num2str(i), '_', num2str((j-1+demux*(ceil(lags/(2*demux))))*(range==1))];
        disp(range==1);
        reuse_block(blk, in_name, 'built-in/inport', ...
            'Position', [30 100+42*(j-1)+42*demux*(i-1) 60 114+42*(j-1)+42*demux*(i-1)], ...
            'Port', num2str(2+j+demux*(i-1)));
        goto_name = [in_name, '_tap'];
        reuse_block(blk, goto_name, 'built-in/Goto', ...
            'Position', [90 100+42*(j-1)+42*demux*(i-1) 140 114+42*(j-1)+42*demux*(i-1)], ...
            'GotoTag', in_name, 'ShowName', 'off');
        add_line(blk, [in_name, '/1'], [goto_name, '/1']);
        if range==1
            for del=1:ceil(lags/(2*demux))
                    reuse_block(blk, ['in', num2str(i), '_', num2str(j-1+demux*(ceil(lags/(2*demux))-del+1)), '_from', num2str(del-1)], 'built-in/From', ...
                        'Position', [170+220*(del-1) 100+42*(j-1)+42*demux*(i-1) 220+220*(del-1) 114+42*(j-1)+42*demux*(i-1)], ...
                        'GotoTag', ['in', num2str(i), '_', num2str(j-1+demux*(ceil(lags/(2*demux))-del+1))], 'ShowName', 'off');
                        %'GotoTag', ['in', num2str(i), '_', num2str(j-1+demux*(del-1))], 'ShowName', 'off');
                    reuse_block(blk, [in_name, '_del', num2str(del)], 'xbsIndex_r4/Delay', ...
                        'Position', [250+220*(del-1) 100+42*(j-1)+42*demux*(i-1) 280+220*(del-1) 114+42*(j-1)+42*demux*(i-1)], ...
                        'latency', '1', 'ShowName', 'off');
                    reuse_block(blk, ['in', num2str(i), '_', num2str(j-1+demux*(ceil(lags/(2*demux))-del)), '_tap'], 'built-in/Goto', ...
                        'Position', [310+220*(del-1) 100+42*(j-1)+42*demux*(i-1) 360+220*(del-1) 114+42*(j-1)+42*demux*(i-1)], ...
                        'GotoTag', ['in', num2str(i), '_', num2str(j-1+demux*(ceil(lags/(2*demux))-del))], 'ShowName', 'off');
                        %'GotoTag', ['in', num2str(i), '_', num2str(j-1+demux*del)], 'ShowName', 'off');
                    add_line(blk, ['in', num2str(i), '_', num2str(j-1+demux*(ceil(lags/(2*demux))-del+1)), '_from', num2str(del-1), '/1'], ... 
                        [in_name, '_del', num2str(del), '/1']);
                    add_line(blk, [in_name, '_del', num2str(del), '/1'], ['in', num2str(i), '_', num2str(j-1+demux*(ceil(lags/(2*demux))-del)), '_tap', '/1']);
            end
        else
            if i==2
                for del=1:lags/demux
                        reuse_block(blk, [in_name, '_from', num2str(del-1)], 'built-in/From', ...
                            'Position', [170+220*(del-1) 100+42*(j-1)+42*demux*(i-1) 220+220*(del-1) 114+42*(j-1)+42*demux*(i-1)], ...
                            'GotoTag', ['in', num2str(i), '_', num2str(j-1+demux*(del-1))], 'ShowName', 'off');
                        reuse_block(blk, [in_name, '_del', num2str(del)], 'xbsIndex_r4/Delay', ...
                            'Position', [250+220*(del-1) 100+42*(j-1)+42*demux*(i-1) 280+220*(del-1) 114+42*(j-1)+42*demux*(i-1)], ...
                            'latency', '1', 'ShowName', 'off');
                        reuse_block(blk, ['in', num2str(i), '_', num2str(j-1+demux*del), '_tap'], 'built-in/Goto', ...
                            'Position', [310+220*(del-1) 100+42*(j-1)+42*demux*(i-1) 360+220*(del-1) 114+42*(j-1)+42*demux*(i-1)], ...
                            'GotoTag', ['in', num2str(i), '_', num2str(j-1+demux*del)], 'ShowName', 'off');
                        add_line(blk, [in_name, '_from', num2str(del-1), '/1'], [in_name, '_del', num2str(del), '/1']);
                        add_line(blk, [in_name, '_del', num2str(del), '/1'], ['in', num2str(i), '_', num2str(j-1+demux*del), '_tap', '/1']);
                end
            end
        end
    end
end

% Create all the lag elements and direct signals to them.
lag_array = (0:lags-1) - (range==1)*(lags-mod(lags,demux))/2;
for i=1:lags
    reuse_block(blk, ['lag', num2str(lag_array(i))], 'quant_xcorr_lib/quant_lag_element', ...
        'Position', [100 200+42*(demux-1)+42*demux*(ants-1)+430*(i-1) 200 600+42*(demux-1)+42*demux*(ants-1)+430*(i-1)], ...
        'demux', num2str(demuxr2), 'lag', num2str(lag_array(i)));
%    disp(['**** ',num2str(lag_array(i)),' ****']);
    for j=1:demux*2
        ant = 1*(j<=demux) + 2*(j>demux);
        stream = (j-1)*(j<=demux) + (j-1-demux)*(j>demux);
        if lag_array(i)>=0
            tapoff = stream*(ant==1) + (stream+abs(lag_array(i)))*(ant==2);
        else
            tapoff = stream*(ant==2) + (stream+abs(lag_array(i)))*(ant==1);
        end
        tapoff_name = ['in', num2str(ant), '_', num2str(tapoff)];
%        disp(tapoff_name);
        
        sep = floor(400/(demux*2+2));
        reuse_block(blk, ['le', num2str(i), '_', tapoff_name], 'built-in/From', ...
            'Position', [30 200+42*(demux-1)+42*demux*(ants-1)+430*(i-1)+(j-1)*sep 80 214+42*(demux-1)+42*demux*(ants-1)+430*(i-1)+(j-1)*sep], ...
            'GotoTag', tapoff_name, 'ShowName', 'off');
        add_line(blk, ['le', num2str(i), '_', tapoff_name, '/1'], ['lag', num2str(lag_array(i)), '/', num2str(j)]);
    end
    reuse_block(blk, ['reset_from', num2str(i)] , 'built-in/From', ...
        'Position', [30 200+42*(demux-1)+42*demux*(ants-1)+430*(i-1)+(2*demux)*sep 80 214+42*(demux-1)+42*demux*(ants-1)+430*(i-1)+(2*demux)*sep], ...
        'GotoTag', 'reset', 'ShowName', 'off');
    reuse_block(blk, ['enable_from', num2str(i)], 'built-in/From', ...
        'Position', [30 200+42*(demux-1)+42*demux*(ants-1)+430*(i-1)+(2*demux+1)*sep 80 214+42*(demux-1)+42*demux*(ants-1)+430*(i-1)+(2*demux+1)*sep], ...
        'GotoTag', 'enable', 'ShowName', 'off');
    add_line(blk, ['reset_from', num2str(i), '/1'], ['lag', num2str(lag_array(i)), '/', num2str(2*demux+1)]);
    add_line(blk, ['enable_from', num2str(i), '/1'], ['lag', num2str(lag_array(i)), '/', num2str(2*demux+2)]);
    reuse_block(blk, ['out', num2str(lag_array(i))], 'built-in/outport', ...
        'Position', [250 407+42*(demux-1)+42*demux*(ants-1)+430*(i-1) 280 421+42*(demux-1)+42*demux*(ants-1)+430*(i-1)], ...
        'Port', num2str(i));
    add_line(blk, ['lag', num2str(lag_array(i)), '/1'], ['out', num2str(lag_array(i)), '/1']);
end

% Clean blocks and finish up.
clean_blocks(blk);

fmtstr = sprintf('antennas=%d, demux=%d, lags=%d', ants, demux, lags);
set_param(blk, 'AttributesFormatString', fmtstr);
save_state(blk, 'defaults', defaults, varargin{:});