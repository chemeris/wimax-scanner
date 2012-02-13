cmake_minimum_required( VERSION 2.8 )
project ( wimax )

if(WIN32)
set ( CMAKE_BINARY_DIR ../build/win )
else(WIN32)
set ( CMAKE_BINARY_DIR ../build/linux )
endif(WIN32)

include_directories ( ../src/ )
include_directories ( ../src/cml/ )
include_directories ( ../src/common/ )
include_directories ( ../src/decoder/ )
include_directories ( ../testbench/ )

set ( HEADERS
	../../src/CFO_Estimator.h
	../../src/ChannelEstimator.h
	../../src/CIC_flt.h
	../../src/dsp_utils.h
	../../src/wimax_consts.h
	../../src/wimax_dem.h
	../../src/cml/convolutional.h
	../../src/common/baseop.h
	../../src/common/comdefs.h
	../../src/common/complex.h
	../../src/common/prbs.h
	../../src/common/stdint_msvc.h
	../../src/common/vect.h
	../../src/common/debug.h
	../../src/decoder/burstdec.h
	../../src/decoder/caralloc.h
	../../src/decoder/fec.h
	../../src/decoder/global.h
	../../src/decoder/ieparser.h
	../../src/decoder/turbo.h
	../../src/decoder/decoder.h
	../../src/decoder/deinterlv.h
	../../src/decoder/demod.h
	../../src/decoder/derepeat.h
	../../src/decoder/macmsg.h	
	../../src/decoder/gsmtap.h
)
set ( SOURCES 
	../../src/CFO_Estimator.cpp
	../../src/ChannelEstimator.cpp
	../../src/dsp_utils.cpp
	../../src/main.cpp
	../../src/wimax_dem.cpp
	../../src/wimax_tables.cpp
	../../src/cml/convolutional.cpp
	../../src/common/debug.cpp
	../../src/decoder/burstdec.cpp
	../../src/decoder/caralloc.cpp
	../../src/decoder/fec.cpp
	../../src/decoder/global.cpp
	../../src/decoder/ieparser.cpp
	../../src/decoder/turbo.cpp
	../../src/decoder/decoder.cpp
)

if(WIN32)
# include MATLAB debug libs
set ( LIBRARY
	ws2_32
	../../testbench/matlab/libmx
	../../testbench/matlab/libeng
	../../src/libfftw3-3	
)
else(WIN32)
set ( LIBRARY
	fftw3
)
endif(WIN32)

if(WIN32)
source_group ( "cml" FILES 
	../src/cml/convolutional.h
	../src/cml/convolutional.cpp
)
source_group ( "common" FILES 
	../src/common/baseop.h
	../src/common/comdefs.h
	../src/common/complex.h
	../src/common/prbs.h
	../src/common/stdint_msvc.h
	../src/common/vect.h
	../src/common/stdint.h
	../src/common/debug.h
	../src/common/debug.cpp
)
source_group ( "decoder" FILES 
	../src/decoder/burstdec.h
	../src/decoder/burstdec.cpp
	../src/decoder/caralloc.h
	../src/decoder/caralloc.cpp
	../src/decoder/fec.h
	../src/decoder/fec.cpp
	../src/decoder/global.h
	../src/decoder/global.cpp
	../src/decoder/ieparser.h
	../src/decoder/ieparser.cpp
	../src/decoder/turbo.h
	../src/decoder/turbo.cpp
	../src/decoder/decoder.h
	../src/decoder/decoder.cpp
	../src/decoder/deinterlv.h
	../src/decoder/demod.h
	../src/decoder/derepeat.h
	../src/decoder/macmsg.h	
	../src/decoder/gsmtap.h
)

add_definitions ( -D_CRT_SECURE_NO_WARNINGS )

endif(WIN32)

add_executable ( wimax  ${HEADERS} ${SOURCES} )
target_link_libraries ( wimax  ${LIBRARY} )
