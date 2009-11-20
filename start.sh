#!/bin/bash
export PLATFORM=lin64
export MATLAB=/opt/MathWorks/R2009a/unix
export XILINX=/opt/Xilinx/11.1/ISE
export XILINX_EDK=/opt/Xilinx/11.1/EDK
export XILINX_DSP=/opt/Xilinx/11.1/DSP_Tools/${PLATFORM}
export BEE2_XPS_LIB_PATH=/SVN/mlib_devel_10_1/xps_lib
export MLIB_ROOT=/SVN/mlib_devel_10_1
export PATH=${XILINX}/bin/${PLATFORM}:${XILINX_EDK}/bin/${PLATFORM}:${PATH}
export LD_LIBRARY_PATH=${XILINX}/bin/${PLATFORM}:${XILINX}/lib/${PLATFORM}:${XILINX_DSP}/sysgen/lib:${LD_LIBRARY_PATH}
export LMC_HOME=${XILINX}/smartmodel/${PLATFORM}/installed_lin
export PATH=${LMC_HOME}/bin:${XILINX_DSP}/common/bin:${PATH}
export INSTALLMLLOC=/opt/MathWorks/R2009a/unix
export TEMP=/tmp/
export TMP=/tmp/
$MATLAB/bin/matlab

