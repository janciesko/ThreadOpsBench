CC = gcc
CCFLAGS = -O3 -std=gnu99

current_dir = $(shell pwd)

QTHREADS_INSTALL_PATH = $(current_dir)/qthreads/install
ARGOBOTS_INSTALL_PATH = $(current_dir)/argobots/install
SOURCEDIR = .

QT_PATHS = -I $(QTHREADS_INSTALL_PATH)/include -L $(QTHREADS_INSTALL_PATH)/lib
AB_PATHS = -I $(ARGOBOTS_INSTALL_PATH)/include -L $(ARGOBOTS_INSTALL_PATH)/lib

SOURCES := $(shell find $(SOURCEDIR) -maxdepth 1 -name '*.c')

all: pthread qthread argobots

default: pthread

pthread: $(SOURCES)
	$(shell echo )
	$(CC) $(CCFLAGS) $^ -DUSE_PTHREADS -lpthread -o run_$@

qthread: $(SOURCES)
	$(CC) $(CCFLAGS) $^ -DUSE_QTHREADS $(QT_PATHS) -lqthread -o run_$@

argobots: $(SOURCES)
	$(CC) $(CCFLAGS) $^ -DUSE_ARGOBOTS $(AB_PATHS) -labt -o run_$@

clean: 
	rm run_* -rf
