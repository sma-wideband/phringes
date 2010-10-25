function coef_load_init(blk, varargin)
% Initialize and configure the coef_load block
%
% coef_load_init(blk, varargin)
%
% blk = The block to configure.
% varargin = {'varname', 'value', ...} pairs
% 
% Valid varnames for this block are:
% nfilters = The number of sub-sample filters (aka interpolation factor)
% ntaps = The number of implemented taps per filter

clog('entering coef_load_init','trace');
% Declare any default values for arguments you might like.
defaults = {'nfilters', 10, 'ntaps', 10};

if same_state(blk, 'defaults', defaults, varargin{:}), return, end
clog('coef_load_init post same_state','trace');
check_mask_type(blk, 'Coef_load');
munge_block(blk, varargin{:});

nfilters = get_var('nfilters', 'defaults', defaults, varargin{:});
ntaps = get_var('ntaps', 'defaults', defaults, varargin{:});

% Find const blocks feeding Mux1
consts = find_system(blk, ...
    'LookUnderMasks','all', ...
    'FollowLinks', 'on', ...
    'SearchDepth', 1, ...
    'RegExp','on', ...
    'Name','const[1-9]');

% Clean up lines from existing consts
for k=1:length(consts)
    % First delete line from const block to Mux1
    delete_line(blk, sprintf('const%d/1',k), sprintf('Mux1/%d',k+1));
end

% Add blocks

a=115;
b=145;
muxp=246+40*(nfilters-2);
n=nfilters;
nbits_counter=ceil(log2(ntaps));
nbits_const=ceil(log2(ntaps*nfilters));
set_param([blk,'/Counter'],'cnt_to',num2str(ntaps-1),'n_bits',num2str(nbits_counter));
set_param([blk,'/AddSub'],'precision','User Defined','n_bits',num2str(nbits_const),'bin_pt','0');
set_param([blk,'/Constant'],'n_bits',num2str(nbits_counter),'const',num2str(ntaps-1));
set_param([blk,'/Mux1'],'Position',[784 194 830 muxp],'inputs',num2str(nfilters));
for k=1:n;
    c=(k-1)*ntaps;
    name=['const',num2str(k)];
    outpin=['const',num2str(k),'/1'];
    inpin=['Mux1/',num2str(k+1)];
    reuse_block(blk, name, 'xbsIndex_r4/Constant','Position',[570 a 630 b], ...
        'arith_type', 'Unsigned', ...
        'n_bits', num2str(nbits_const), ...
        'bin_pt', '0', ...
        'const',num2str(c));
    a=a+50;
    b=b+50;
    add_line(blk,num2str(outpin),num2str(inpin),'autorouting','off')
end	

clean_blocks(blk);

save_state(blk, 'defaults', defaults, varargin{:});
clog('exiting coef_load_init','trace');
