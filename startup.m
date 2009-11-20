sysgen_startup
addpath('/SVN/mlib_devel_10_1/xps_library');
addpath('/SVN/mlib_devel_10_1/casper_library');
addpath('/SVN/mlib_devel_10_1/gavrt_library');
system_dependent('RemoteCWDPolicy','reload')
system_dependent('RemotePathPolicy','reload')
load_system('casper_library');
