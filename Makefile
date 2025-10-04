#
#	Updater Makefile
#

all: compile

compile build:
	@make -C src

clean:
	@make -C src clean

cache: clean
	@me cache

format:
	uncrustify -q -c .uncrustify --replace --no-backup src/*.{c,h}

install:
	sudo cp build/*/bin/updater /usr/local/bin
	sudo cp doc/updater.1 /usr/local/share/man/man1/

test:
	@tm test

LOCAL_MAKEFILE := $(strip $(wildcard ./.local.mk))

ifneq ($(LOCAL_MAKEFILE),)
include	$(LOCAL_MAKEFILE)
endif
