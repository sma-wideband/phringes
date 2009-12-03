sysgen_startup
mlib_root = getenv('MLIB_ROOT');
addpath([mlib_root,'/xps_library']);
addpath([mlib_root,'/casper_library']);
addpath([mlib_root,'/gavrt_library']);
system_dependent('RemoteCWDPolicy','reload')
system_dependent('RemotePathPolicy','reload')
load_system('casper_library');
