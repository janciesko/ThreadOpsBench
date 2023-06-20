CC = gcc
CCFLAGS = -O3
CPP = g++
current_dir = $(shell pwd)

QTHREADS_INSTALL_PATH = $(current_dir)/qthreads/install
ARGOBOTS_INSTALL_PATH = $(current_dir)/argobots/install
HPX_INSTALL_PATH = $(current_dir)/hpx/install
SOURCEDIR = .

QT_PATHS = -I$(QTHREADS_INSTALL_PATH)/include -L$(QTHREADS_INSTALL_PATH)/lib
AB_PATHS = -I$(ARGOBOTS_INSTALL_PATH)/include -L$(ARGOBOTS_INSTALL_PATH)/lib
HPX_PATHS = -I$(HPX_INSTALL_PATH)/include -I/projects/x86-64-skylake/tpls/boost/1.81.0/gcc/11.2.0/base/ibpuap5/include/ -L$(HPX_INSTALL_PATH)/lib64/ -L/projects/x86-64-skylake/tpls/boost/1.81.0/gcc/11.2.0/base/ibpuap5/lib -lhpx_iostreams

#SOURCES := $(shell find $(SOURCEDIR) -maxdepth 1 -name '*.c')

SOURCES_ABT = benchmark_argobots.c
SOURCES_Q = benchmark_qthreads.c
SOURCES_ASYNC = benchmark_stdasync.cpp
SOURCES_LEGION = benchmark_legion.cpp
SOURCES_HPX = benchmark_hpxasync.cpp
SOURCES_P = benchmark_pthreads.c
SOURCES_OMP = benchmark_openmp.c
all: pthreads qthreads argobots stdasync hpx

default: pthreads

stdasync: $(SOURCES_ASYNC)
	$(CPP) $(CCFLAGS) $^ -lpthread -o run_$@

pthreads: $(SOURCES_P)
	$(shell echo )
	$(CC) $(CCFLAGS) $^ -lpthread -o run_$@

qthreads: $(SOURCES_Q)
	$(CC) $(CCFLAGS) $^ $(QT_PATHS) -lqthread -o run_$@

argobots: $(SOURCES_ABT)
	$(CC) $(CCFLAGS) $^ $(AB_PATHS) -labt -o run_$@

hpx: $(SOURCES_HPX)
	$(CPP)  $(CCFLAGS) $^  `pkg-config --cflags --libs hpx_application` $(HPX_PATHS) -lhpx -o run_$@
#``pkg-config --cflags --libs hpx_application``\
#    -L${HOME}/my_hpx_libs -lhpx_hello_world -lhpx_iostreams
	

openmp: $(SOURCES_OMP)
	$(CC) $(CCFLAGS) $^ -fopenmp -o run_$@
clean: 
	rm run_* -rf
