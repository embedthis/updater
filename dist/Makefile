#
#	Update Makefile
#
OS := $(shell uname | sed 's/CYGWIN.*/windows/;s/Darwin/macosx/' | tr '[A-Z]' '[a-z]')

ifeq ($(OS),macosx)
	IFLAGS	:= -I /opt/homebrew/include
	LFLAGS	:= -L /opt/homebrew/lib
endif

all: compile

compile build: update

update.o: update.c
	clang $(IFLAGS) -c update.c

update: update.o 
	clang $(IFLAGS) $(LFLAGS) -o update main.c update.o -lssl -lcrypto

clean:
	rm -f update.o main.o update

cache: clean
	cp README* apply.sh main.c update.h update.c Makefile dist
	cache

LOCAL_MAKEFILE := $(strip $(wildcard ./.local.mk))

ifneq ($(LOCAL_MAKEFILE),)
include $(LOCAL_MAKEFILE)
endif
