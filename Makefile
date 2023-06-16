CC = gcc
CCFLAGS = -O3
CPP = g++
current_dir = $(shell pwd)

QTHREADS_INSTALL_PATH = $(current_dir)/qthreads/install
ARGOBOTS_INSTALL_PATH = $(current_dir)/argobots/install
SOURCEDIR = .

QT_PATHS = -I$(QTHREADS_INSTALL_PATH)/include -L$(QTHREADS_INSTALL_PATH)/lib
AB_PATHS = -I$(ARGOBOTS_INSTALL_PATH)/include -L$(ARGOBOTS_INSTALL_PATH)/lib

#SOURCES := $(shell find $(SOURCEDIR) -maxdepth 1 -name '*.c')

SOURCES_ABT = benchmark_argobots.c
SOURCES_Q = benchmark_qthreads.c
SOURCES_ASYNC = benchmark_stdasync.cpp
SOURCES_LEGION = benchmark_legion.cpp
SOURCES_HPX =  benchmark_coroutine.cpp
SOURCES_P = benchmark_pthreads.c

all: pthreads qthreads argobots stdasync

default: pthreads

stdasync: $(SOURCES_ASYNC)
	$(CPP) $(CCFLAGS) $^ -lpthread -o run_$@

pthreads: $(SOURCES_P)
	$(shell echo )
	$(CC) $(CCFLAGS) $^ -DUSE_PTHREADS -lpthread -o run_$@

qthreads: $(SOURCES_Q)
	$(CC) $(CCFLAGS) $^ -DUSE_QTHREADS $(QT_PATHS) -lqthread -o run_$@

argobots: $(SOURCES_ABT)
	$(CC) $(CCFLAGS) $^ -DUSE_ARGOBOTS $(AB_PATHS) -labt -o run_$@

clean: 
	rm run_* -rf
