function shift_reg_init(blk, varargin)
% Initialize and configure the shift_reg block
%
% shift_reg_init(blk, varargin)
%
% blk = The block to configure.
% varargin = {'varname', 'value', ...} pairs
% 
% Valid varnames for this block are:
% ntaps = The number of implemented taps
% bin_pt = Binary point (of input value?)

clog('entering shift_reg_init','trace');
% Declare any default values for arguments you might like.
defaults = {'ntaps', 10, 'bin_pt', 6};

if same_state(blk, 'defaults', defaults, varargin{:}), return, end
clog('shift_reg_init post same_state','trace');
check_mask_type(blk, 'Shift Reg');
munge_block(blk, varargin{:});

ntaps = get_var('ntaps', 'defaults', defaults, varargin{:});
bin_pt = get_var('bin_pt', 'defaults', defaults, varargin{:});

% Delete all lines
delete_lines(blk);

% Add tap blocks

a=235;
b=370;
init=0;
bp=bin_pt;
for k=1:ntaps;
	name=['tap',num2str(k)];
	outpin=['tap',num2str(k),'/1'];
	inpin=['Mux1/',num2str(k+1)];
	reuse_block(blk, name, 'beamform/filter_tap', 'Position',[a 185 b 619], 'bnpnt',num2str(bp));
	a=a+180;
	b=b+180;
	inpin1=['tap',num2str(k),'/1'];
	inpin2=['tap',num2str(k),'/2'];
	inpin3=['tap',num2str(k),'/3'];
	inpin4=['tap',num2str(k),'/4'];
	inpin5=['tap',num2str(k),'/5'];
	inpin6=['tap',num2str(k),'/6'];
	inpin7=['tap',num2str(k),'/7'];
	inpin8=['tap',num2str(k),'/8'];
	inpin9=['tap',num2str(k),'/9'];
	inpin10=['tap',num2str(k),'/10'];
	outpin1=['Update','/1'];
	if init==0
		outpin2=['Serial In/1'];
		outpin3=['data_1/1'];
		outpin4=['data_2/1'];
		outpin5=['data_3/1'];
		outpin6=['data_4/1'];
		outpin7=['Constant/1'];
		outpin8=['Constant/1'];
		outpin9=['Constant/1'];
		outpin10=['Constant/1'];
		init=1;
	else
		outpin2=['tap',num2str(k-1),'/1'];
		outpin3=['tap',num2str(k-1),'/2'];
		outpin4=['tap',num2str(k-1),'/3'];
		outpin5=['tap',num2str(k-1),'/4'];
		outpin6=['tap',num2str(k-1),'/5'];
		outpin7=['tap',num2str(k-1),'/6'];
		outpin8=['tap',num2str(k-1),'/7'];
		outpin9=['tap',num2str(k-1),'/8'];
		outpin10=['tap',num2str(k-1),'/9'];
	end	
	add_line(blk,num2str(outpin1),num2str(inpin1),'autorouting','on');
	add_line(blk,num2str(outpin2),num2str(inpin2),'autorouting','on');
	add_line(blk,num2str(outpin3),num2str(inpin3),'autorouting','on');
	add_line(blk,num2str(outpin4),num2str(inpin4),'autorouting','on');
	add_line(blk,num2str(outpin5),num2str(inpin5),'autorouting','on');
	add_line(blk,num2str(outpin6),num2str(inpin6),'autorouting','on');
	add_line(blk,num2str(outpin7),num2str(inpin7),'autorouting','on');
	add_line(blk,num2str(outpin8),num2str(inpin8),'autorouting','on');
	add_line(blk,num2str(outpin9),num2str(inpin9),'autorouting','on');
	add_line(blk,num2str(outpin10),num2str(inpin10),'autorouting','on');
end
outpin2=['tap',num2str(ntaps),'/10'];
outpin3=['tap',num2str(ntaps),'/11'];
outpin4=['tap',num2str(ntaps),'/12'];
outpin5=['tap',num2str(ntaps),'/13'];
add_line(blk,num2str(outpin2),num2str('fil_out_1/1'),'autorouting','on');
add_line(blk,num2str(outpin3),num2str('fil_out_2/1'),'autorouting','on');
add_line(blk,num2str(outpin4),num2str('fil_out_3/1'),'autorouting','on');
add_line(blk,num2str(outpin5),num2str('fil_out_4/1'),'autorouting','on');

clean_blocks(blk);

save_state(blk, 'defaults', defaults, varargin{:});
clog('exiting shift_reg_init','trace');
